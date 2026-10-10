{ config, lib, pkgs, ... }:

let
  domain = "fschn.org";

  # config.tailnet.<host> -> string
  tailnetIp = host: toString config.tailnet.${host};

  guiAddress = tailnetIp "helio";
  guiPort = 3000;

  # ---------------------------------------------------------------------------
  # DNS rewrites: "<subdomain>" = "<tailnet host>"
  # ---------------------------------------------------------------------------
  rewriteMap = {
    adguard = "helio";
    cloud = "omhe";
    monitor = "omhe";
    jellyfin = "omhe";
    prometheus = "omhe";
    deluge = "omhe";
    photos = "omhe";
    paperless = "omhe";
    paperless-gpt = "omhe";
    radarr = "omhe";
    bazarr = "omhe";
    scrutiny-omhe = "omhe";
    syncthing-omhe = "omhe";
    scrutiny-oide = "oide";
    scrutiny-rainbow = "rainbow";
    syncthing-rainbow = "rainbow";
    ai = "rainbow";
    fritzbox-eltern = "berry";
    adguard-eltern = "berry";
    syncthing-berry = "berry";
    # ffsync = "omhe";
    # office = "omhe";
  };

  # ---------------------------------------------------------------------------
  # Filter lists
  # ---------------------------------------------------------------------------
  agf = "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master";
  hagezi = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock";

  # AdGuard "sections" lists: <agf>/<folder>/sections/<name>.txt
  sections = folder: names: map (n: "${agf}/${folder}/sections/${n}.txt") names;

  # Only lists with network/domain rules are kept, and overlapping broad lists
  # are avoided: HaGeZi recommends running a single broad list (Pro), so OISD
  # big, EasyList/EasyPrivacy, Spam404, Disconnect and the generic AdGuard ad
  # server lists (all largely covered by Pro + TIF) were removed.
  filterUrls = lib.concatLists [
    [
      # broad list + threat intelligence feeds
      "${hagezi}/pro.txt"
      "${hagezi}/tif.txt"
      # not part of Pro: dynamic-DNS and web-hoster abuse
      "${hagezi}/dyndns.txt"
      "${hagezi}/hoster.txt"
      # newly registered phishing domains (30 days)
      "https://raw.githubusercontent.com/xRuffKez/NRD/refs/heads/main/lists/30-day_phishing/adblock/nrd-phishing-30day_adblock.txt"
      # german-region ad servers (not covered by Pro)
      "https://easylist-downloads.adblockplus.org/easylistgermany.txt"
      # adguard spyware/tracking servers (combined list, includes all Spyware sections)
      "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt"
    ]

    # small, distinct adguard lists: CNAME-cloaked trackers and cryptominers
    (sections "BaseFilter" [ "adservers_firstparty" "cryptominers" ])
    (sections "GermanFilter" [ "adservers" ])

    # custom list (URL instead of a local path: AGH rejects /nix/store paths)
    [ "https://raw.githubusercontent.com/fschn90/nixos/refs/heads/modules/adguard-mobile-custom.txt" ]
  ];

  # ---------------------------------------------------------------------------
  # Blocked-services schedule
  # ---------------------------------------------------------------------------
  weekdayWindow = { start = "17h"; end = "22h"; };
  weekendWindow = { start = "12h"; end = "24h"; };
in
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      http.address = "${guiAddress}:${toString guiPort}";

      theme = "auto";

      dns = {
        # Fewer upstreams = less wasted traffic in parallel mode. Filtering is
        # done locally, so the unfiltered AdGuard resolver is used.
        upstream_dns = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://dns.mullvad.net/dns-query"
          "https://dns-unfiltered.adguard.com/dns-query"
        ];
        upstream_mode = "parallel";
        use_http3_upstreams = true;
        serve_http3 = true;

        bootstrap_dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        fallback_dns = [ "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

        # Cache: 16 MiB, optimistic (serve stale + refresh in background)
        cache_size = 16777216;
        cache_ttl_min = 600;
        cache_ttl_max = 43200;
        cache_optimistic = true;

        enable_dnssec = true;
        # Only reachable via tailnet, so rate limiting is unnecessary.
        ratelimit = 0;
        refuse_any = true;
        max_goroutines = 500;
      };

      statistics = {
        enable = true;
        interval = "720h";
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        filters_update_interval = 12;
        parental_enabled = false;
        safe_search.enabled = false;

        rewrites = lib.mapAttrsToList
          (name: host: {
            domain = "${name}.${domain}";
            answer = tailnetIp host;
            enabled = true;
          })
          rewriteMap;

        # blocked_services = {
        #   ids = [ "linkedin" ];
        #   schedule =
        #     lib.genAttrs [ "mon" "tue" "wed" "thu" "fri" ] (_: weekdayWindow)
        #     // lib.genAttrs [ "sat" "sun" ] (_: weekendWindow)
        #     // { time_zone = "Europe/Vienna"; };
        # };
      };

      filters = map (url: { enabled = true; inherit url; }) filterUrls;
    };
  };

  # Password hash lives in secrets/main.yaml (key: adguard -> password_hash).
  sops.secrets."adguard/password_hash".restartUnits = [ "adguardhome.service" ];

  # The module's settings end up in the world-readable Nix store, so the users
  # entry is injected at service start from a systemd credential instead.
  systemd.services.adguardhome.serviceConfig.ExecStartPre = lib.mkAfter [
    "+${pkgs.writeShellScript "adguardhome-inject-user" ''
    set -euo pipefail
    cfg="$STATE_DIRECTORY/AdGuardHome.yaml"
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT

    hash="$(cat ${config.sops.secrets."adguard/password_hash".path})" \
      ${pkgs.yq-go}/bin/yq eval \
      '.users = [{"name": "fschn90", "password": strenv(hash)}]' \
      "$cfg" > "$tmp"

    # write through the existing file so owner/mode are preserved
    cat "$tmp" > "$cfg"
  ''}"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."adguard.${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/".proxyPass = "http://${guiAddress}:${toString guiPort}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
}
