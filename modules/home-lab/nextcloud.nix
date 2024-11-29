{ pkgs, config, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "cloud.fschn.org";
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql"; # nextcloud is not optimised for sqlite thus pgsql
      adminpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
    };
    configureRedis = true; # for caching
    maxUploadSize = "50G"; # bigger file size for eg movies
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts notes onlyoffice tasks
        deck phonetrack polls cospend
        music gpoddersync;
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    home = "/tank/Nextcloud";
    package = pkgs.nextcloud30;
    settings = {
      overwriteprotocol = "https";
      loglevel = 1;
      log_type = "file";
      logfile = "/tank/Nextcloud/data/nextcloud.log";
      log_type_audit = "file";
      logfile_audit = "/tank/Nextcloud/data/audit.log";
    };
  };

  # secret depoloyment for nextcloud admin password
  sops.secrets."Nextcloud/admin/Password" = {
    mode = "0400";
    path = "/tank/Nextcloud/Admin-Password";
    owner = "nextcloud";
  };

  # reverse proxy
  services.nginx = {
    virtualHosts.${config.services.nextcloud.hostName} = {
      useACMEHost = "fschn.org";
      forceSSL = true;
    };
  };

  # secret deployment for nextcloud-exporter
  sops.secrets."Nextcloud/authToken" = {
    path = "/tank/Nextcloud/authToken";
    owner = "nextcloud";
    mode = "0440";
  };

}


