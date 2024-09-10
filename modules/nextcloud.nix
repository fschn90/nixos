{ pkgs, config, lib, ... }:

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
    maxUploadSize = "16G"; # bigger file size for eg movies
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes onlyoffice tasks 
        deck bookmarks polls cookbook music maps phonetrack; 
        # cospend throws errors
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
  };

  sops.secrets."Nextcloud/admin/Password" = {
    mode = "0400";
    path = "/tank/Nextcloud/Admin-Password";
    owner = "nextcloud";
  };

  services.nginx = {
    virtualHosts.${config.services.nextcloud.hostName} = {
      useACMEHost = "fschn.org";
      forceSSL = true;
    };
  };

}


