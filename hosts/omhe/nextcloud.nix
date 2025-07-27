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
      # integration_paperless; # doesnt seem to work yet
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    home = "/tank/Nextcloud";
    package = pkgs.nextcloud31;
    settings = {
      # settings for nextcloud log scraping with promtail and loki
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

  # reverse proxies for nextcloud and onlyoffice documentserver
  services.nginx = {
    virtualHosts = {
      ${config.services.nextcloud.hostName} = {
        useACMEHost = "fschn.org";
        forceSSL = true;
      };
      # ${config.services.onlyoffice.hostname} = {
      #   useACMEHost = "fschn.org";
      #   forceSSL = true;
      # };
    };
  };


  # # enabling onlyoffice documentserver
  # services.onlyoffice = {
  #   enable = true;
  #   jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
  #   hostname = "office.fschn.org";
  # };

  # # secret deployment for onlyoffice documentserver
  # sops.secrets."onlyoffice/jwtSecretFile" = {
  #   owner = "onlyoffice";
  # };




  services.prometheus.exporters.zfs.enable = true;
  services.prometheus.exporters.nginx.enable = true;
  # services.prometheus.exporters.nginxlog.enable = true;
  services.prometheus.exporters.smartctl.enable = true;
  services.prometheus.exporters.postgres.enable = true;
  services.prometheus.exporters.postgres.runAsLocalSuperUser = true;
  services.prometheus.exporters.nextcloud = {
    enable = true;
    tokenFile = config.sops.secrets."Nextcloud/authToken".path;
    url = "https://${builtins.toString config.services.nextcloud.hostName}";
    # to avoid time out errors in the beginning, seems to be running much faster now, maybe not needed anymore, ie default value enough
    timeout = "60s";
    extraFlags = [
      "--tls-skip-verify true"
    ];
  };

  # # make sure nextcloud-exporter has access to secret
  # users.users.nextcloud-exporter.extraGroups = [ "nextcloud" ];

  # secret deployment for nextcloud-exporter
  sops.secrets."Nextcloud/authToken" = {
    path = "/tank/Nextcloud/authToken";
    owner = "nextcloud-exporter";
    mode = "0440";
  };
  users.users.nextcloud-exporter.extraGroups = [ "nextcloud" ];
}


