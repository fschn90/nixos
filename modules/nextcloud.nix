{ pkgs, config, lib, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "cloud.fschn.org";
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql"; # nextcloud is not optimised for sqlite thus pgsql
      # adminuser = "admin"; 
      adminpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
    };
    configureRedis = true; # for caching
    maxUploadSize = "16G"; # bigger file size for eg movies
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts notes onlyoffice tasks 
        deck maps phonetrack polls cospend;
        memories = pkgs.fetchNextcloudApp {
          sha256 = "sha256-DJPskJ4rTECTaO1XJFeOD1EfA3TQR4YXqG+NIti0UPE=";
          url = "https://github.com/pulsejet/memories/releases/download/v7.3.1/memories.tar.gz";
          license = "agpl3Only";
        };
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    home = "/tank/Nextcloud";
    package = pkgs.nextcloud29; # to avoid build error with nextcloud27 marked as insecure EOL
    settings = {
      # settings for loki scrape also still WIP on loki end
      overwriteprotocol = "https";
      loglevel = 1;
      log_type = "file";
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
 
  # WIP TODO: add exception for nextcloud-exporter and reset timeout to default 5s   https://github.com/xperimental/nextcloud-exporter/issues/108
  services.prometheus.exporters.nextcloud.enable = true;
  services.prometheus.exporters.nextcloud.tokenFile = config.sops.secrets."Nextcloud/authToken".path;
  services.prometheus.exporters.nextcloud.url = "https://${builtins.toString config.services.nextcloud.hostName}"; 
  # to avoid time out errors in the beginning, seems to be running much faster now, maybe not needed anymore, ie default value enough
  services.prometheus.exporters.nextcloud.timeout = "60s";
  services.prometheus.exporters.nextcloud.extraFlags = [
    "--tls-skip-verify true"
  ];

  # make sure nextcloud-exporter has access to secret
  users.users.nextcloud-exporter.extraGroups = [ "nextcloud" ];

  # secret deployment for nextcloud-exporter
  sops.secrets."Nextcloud/authToken" = {
    path = "/tank/Nextcloud/authToken";
    owner = "nextcloud";
    mode = "0440";
  };

}


