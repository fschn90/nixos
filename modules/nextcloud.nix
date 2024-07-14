{ pkgs, config, lib, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "cloud.home";
    # https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql"; # nextcloud is not optimised for sqlite thus pgsql
      adminpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
    };
    configureRedis = true; # for caching
    maxUploadSize = "16G"; # bigger file size for eg movies
    extraApps = with config.services.nextcloud.package.packages.apps; {
     inherit calendar contacts mail notes onlyoffice tasks;
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    home = "/mnt/Nextcloud-test";
    package = pkgs.nextcloud29; # to avoid build error with nextcloud27 marked as insecure EOL
    # settings.trusted_domains = [ "oide.tail9e2438.ts.net"];
  };

  sops.secrets."Nextcloud/admin/Password" = {
    mode = "0400";
    path = "/mnt/Nextcloud-test/Password";
    owner = "nextcloud";
  };



  services.coredns.enable = true;
  services.coredns.config =
  ''
    . {
      # Cloudflare
      forward . 1.1.1.1 1.0.0.1 
      # forward . 100.100.100.100
      # forward . 100.100.100.100 tls://1.1.1.1 tls://1.0.0.1
      # forward . tls://1.1.1.1 tls://1.0.0.1
      cache
    }

    home {
      template IN A  {
          # answer "{{ .Name }} 0 IN A 127.0.0.1"
          answer "{{ .Name }} 0 IN A 100.79.181.86"
      }
    }
  '';
  # networking.networkmanager.insertNameservers = [ "127.0.0.1" ];
  # networking.networkmanager.insertNameservers = [ "100.79.181" ];
  # networking.networkmanager.appendNameservers = [ "1.1.1.1" "1.0.0.1" ]
  # networking.nameservers = [ "100.100.100.100" "1.1.1.1" "1.0.0.1" ]

  services.nginx = {
    enable = true;
    # recommendedGzipSettings = true;
    # recommendedOptimisation = true;
    # recommendedProxySettings = true; 
    # recommendedTlsSettings = true;
    virtualHosts.${config.services.nextcloud.hostName} = {
      # enableACME = true;
      # forceSSL = true;
      # sslCertificate =
      # sslCertificateKey =
      locations = {
         "/" = {
           # proxyPass = "localhost";
           # proxyPass = "http://127.0.0.1:8080";
           proxyPass = "http://100.79.181.86:8080";
        };
      };
    };
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "hello@fschn.org";
  # };
 
  # security.pki.certificateFiles # for self signed root openssl cert

}
