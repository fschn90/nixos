{ pkgs, config, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "localhost";
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
    settings.trusted_domains = [ "oide.tail9e2438.ts.net"];
  };

  sops.secrets."Nextcloud/admin/Password" = {
    mode = "0400";
    path = "/mnt/Nextcloud-test/Password";
    owner = "nextcloud";
  };

  # services.nginx = {
  #   enable = true;
  #   recommendedGzipSettings = true;
  #   recommendedOptimisation = true;
  #   recommendedProxySettings = true;
  #   recommendedTlsSettings = true;
  #   virtualHosts.${config.services.nextcloud.hostName} = {
  #     enableACME = true;
  #     forceSSL = true;
  #     locations = {
  #        "/" = {
  #          proxyPass = "localhost";
  #       };
  #     };
  #   };
  # };
  # 
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "hello@fschn.org";
  # };
 
}
