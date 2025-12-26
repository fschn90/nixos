{ config, ... }:

{

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      http = {
        # Web interface IP address with port to listen on.
        address = "${toString config.tailnet.omhe}:3000";
      };
      dns = {
        # List of upstream DNS servers
        upstream_dns = [
          https://cloudflare-dns.com/dns-query
          https://1.1.1.1/dns-query
          https://1.0.0.1/dns-query
          # https://dns.quad9.net/dns-query
          https://dns.quad9.net:443/dns-query
          https://dns.adguard.com/dns-query
          https://dns.mullvad.net/dns-query
          https://dns-unfiltered.adguard.com/dns-query
          tls://dns.adguard.com
          tls://cloudflare-dns.com
          # tls://dns.quad9.net
        ];
        # Enables DNS-over-HTTP/3 for DNS-over-HTTPS upstreams that support it.
        use_http3_upstreams = true;
        # Enables DNS-over-HTTP/3 serving for DNS-over-HTTPS clients as well as for the web UI.
        serve_http3 = true;
        # List of DNS servers used for initial hostname resolution in case an upstream server name is a hostname.
        bootstrap_dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        # List of fallback DNS servers used when upstream DNS servers are not responding.
        # fallback_dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        fallback_dns = [ "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        # DNS cache size (in bytes).
        # cache_size = 33554432;
        cache_size = 67108864;
        #The minimum TTL override, in seconds. If the TTL of a response from upstream is below this value, the TTL is replaced with it.
        cache_ttl_min = 2400;
        # The maximum TTL override, in seconds. If the TTL of a response from upstream is above this value, the TTL is replaced with it.
        cache_ttl_max = 86400;
        # Make AdGuard Home respond from the cache even when the entries are expired and also try to refresh them. such responses is 10 seconds.
        cache_optimistic = true;
        upstream_mode = "parallel";
        # Set DNSSEC flag in the outgoing DNS requests and check the result.
        enable_dnssec = true;
        # The theme of UI.
        theme = "auto";
        # DDoS protection, specifies how many queries per second AdGuard Home should handle. Anything above that is silently dropped. Safe to disable if DNS server is not available from internet.
        ratelimit = 0;
        # rarely needed, so refusing to serve them mitigates against attackers trying to use your DNS as a reflection. 
        refuse_any = true;
        # Maximum number of parallel goroutines for processing incoming requests.
        max_goroutines = 500;


      };
      statistics = {
        enable = true;
        # Time interval for statistics. It's a string with human-readable duration between an hour (1h) and a year (8760h).
        # interval = "8760h";
        interval = "720h";
      };
      # For web interface UI.
      users = [
        {
          name = "fschn";
          # htpasswd encryped password for web interface UI.
          password = "$2y$10$pB1oLZdzV5TdkuE2dUxlPuLQsFP.VHG8saWrgygQxsoNL5AgOFPUa";
        }
      ];
      # # somehow crashes my rebuild of adguard home 
      # clients = 
      #   {
      #     persistent = [
      #       {
      #         name = "omhe";
      #         ids = [ "${toString config.tailnet.omhe}" ];
      #         use_global_settings = true;
      #       }
      #     ];
      #   };
      filtering = {
        # Whether any kind of filtering and protection should be performed.
        protection_enabled = true;
        # Whether filtering of DNS requests based on rule lists should be performed.
        filtering_enabled = true;
        # Time interval in hours for updating filters.
        filters_update_interval = 12;
        # List of legacy DNS rewrites, where domain is the domain or wildcard you want to be rewritten and answer is IP address, CNAME record, A or AAAA special values. Special value A keeps A records from the upstream and AAAA keeps AAAA values from the upstream.
        rewrites = [
          {
            domain = "adguard.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "cloud.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "monitor.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "jellyfin.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "scrutiny-omhe.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "scrutiny-oide.fschn.org";
            answer = "${toString config.tailnet.oide}";
          }
          {
            domain = "scrutiny-rainbow.fschn.org";
            answer = "${toString config.tailnet.rainbow}";
          }
          {
            domain = "prometheus.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "deluge.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "ffsync.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "photos.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "paperless.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "syncthing-omhe.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "syncthing-rainbow.fschn.org";
            answer = "${toString config.tailnet.rainbow}";
          }
          {
            domain = "office.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "ai.fschn.org";
            answer = "${toString config.tailnet.omhe}";
          }
          {
            domain = "fritzbox-eltern.fschn.org";
            answer = "${toString config.tailnet.berry}";
          }
          {
            domain = "adguard-eltern.fschn.org";
            answer = "${toString config.tailnet.berry}";
          }
          {
            domain = "syncthing-berry.fschn.org";
            answer = "${toString config.tailnet.berry}";
          }

        ];

        blocked_services = {
          ids = [
            "linkedin"
            "mastodon"
          ];
          schedule = {
            mon = {
              start = "17h";
              end = "22h";
            };
            tue = {
              start = "17h";
              end = "22h";
            };
            wed = {
              start = "17h";
              end = "22h";
            };
            thu = {
              start = "17h";
              end = "22h";
            };
            fri = {
              start = "17h";
              end = "22h";
            };
            sat = {
              start = "12h";
              end = "24h";
            };
            sun = {
              start = "12h";
              end = "24h";
            };
            time_zone = "Europe/Vienna";
          };
        };
        # Parental control-based DNS requests filtering.
        parental_enabled = false;
        # Enforcing "Safe search" option for search engines, when possible.
        safe_search = {
          enabled = false;
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map (url: { enabled = true; url = url; }) [
        #other
        https://big.oisd.nl
        https://raw.githubusercontent.com/Spam404/lists/master/adblock-list.txt
        https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
        https://easylist-downloads.adblockplus.org/easylistgermany.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/MobileFilter/sections/adservers.txt
        https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt
        https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt
        https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt
        https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt
        https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/dyndns.txt
        https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/hoster.txt
        # https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds.txt
        https://raw.githubusercontent.com/xRuffKez/NRD/refs/heads/main/lists/30-day_phishing/adblock/nrd-phishing-30day_adblock.txt
        # https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt
        https://raw.githubusercontent.com/laylavish/uBlockOrigin-HUGE-AI-Blocklist/main/noai_hosts.txt

        # easylist
        https://easylist.to/easylist/easylist.txt
        https://easylist.to/easylist/easyprivacy.txt
        https://secure.fanboy.co.nz/fanboy-annoyance.txt
        https://easylist.to/easylist/fanboy-social.txt

        # adguard annoyances
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Cookies/sections/cookies_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Cookies/sections/cookies_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/MobileApp/sections/mobile-app_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/MobileApp/sections/mobile-app_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Other/sections/annoyances.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Other/sections/tweaks.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/popups_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/popups_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/push-notifications_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/push-notifications_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/subscriptions_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Popups/sections/subscriptions_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/AnnoyancesFilter/Widgets/sections/widgets.txt

        # adguard basefilter
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers_firstparty.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/antiadblock.txt
        # https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/banner_sizes.txt # doesnt seem to exist anymore
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/content_blocker.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/cryptominers.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/foreign.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/general_elemhide.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/general_extensions.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/general_url.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/replace.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/specific.txt

        # adguard german
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/adservers.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/antiadblock.txt
        # https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/general_elemhide.txt # doesnt seem to exist anymore
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/general_extensions.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/general_url.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/replace.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/GermanFilter/sections/specific.txt

        # adguard spyware
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/cookies_general.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/cookies_specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/general_elemhide.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/general_extensions.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/general_url.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/mobile.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/mobile_allowlist.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/specific.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/tracking_servers.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/SpywareFilter/sections/tracking_servers_firstparty.txt

        # adguard trackingparam
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/TrackParamFilter/sections/general_url.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/TrackParamFilter/sections/specific.txt

        ./adguard-mobile-custom.txt
        ## url to same file as above to avoid error:  updating filter from url "/nix/store/h6iysbz4sx69w7j9wk0gnxm1mq88jsx4-adguard-mobile-custom.txt": path "/nix/store/h6iysbz4sx69w7j9wk0gnxm1mq88jsx4-adguard-mobile-custom.txt" does not match safe patterns
        ## really not sure why this doesnt work..
        https://raw.githubusercontent.com/fschn90/nixos/refs/heads/main/hosts/omhe/adguard-mobile-custom.txt
      ];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."adguard.fschn.org" = {
      useACMEHost = "fschn.org";
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://${toString config.tailnet.omhe}:3000";
        };
      };
    };
  };

}
