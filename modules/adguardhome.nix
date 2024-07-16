{

  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "100.106.245.44:3000";
      };
      dns = {
        upstream_dns = [
          # Example config with quad9
          # "9.9.9.9#dns.quad9.net"
          # "149.112.112.112#dns.quad9.net"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"

          "https://cloudflare-dns.com/dns-query"
          "tls://unfiltered.adguard-dns.com"
        ];

        bootstrap_dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        fallback_dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        cache_optimistic = true;
        upstream_mode = "parallel";
        enable_dnssec = true;
        theme = "auto";
  
      };
      statistics = {
        enable = true;
        interval = "8760h";
      };
      users = [
        {
          name = "fschn";
          password = "$2y$10$pB1oLZdzV5TdkuE2dUxlPuLQsFP.VHG8saWrgygQxsoNL5AgOFPUa";
        }
      ];
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        filters_update_interval = 1;
        rewrites = [
          {
            domain = "*.home";
            answer = "100.106.245.44";
          }
        ];

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        # "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        # "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt
        https://big.oisd.nl
        https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt
        https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/MobileFilter/sections/adservers.txt
        https://raw.githubusercontent.com/easylist/easylist/master/easyprivacy/easyprivacy_trackingservers.txt
      ];
    };
  };

  services.nginx = {
    enable = true;
    # recommendedGzipSettings = true;
    # recommendedOptimisation = true;
    # recommendedProxySettings = true; 
    # recommendedTlsSettings = true;
    virtualHosts."adguard.home" = {
      # enableACME = true;
      # forceSSL = true;
      # sslCertificate =
      # sslCertificateKey =
      locations = {
         "/" = {
           # proxyPass = "localhost";
           # proxyPass = "http://127.0.0.1:8080";
           proxyPass = "http://100.106.245.44:3000";
        };
      };
    };
  };

}
