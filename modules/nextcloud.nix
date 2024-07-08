{ pkgs, config, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    database.createLocally = true;
    config = {
      dbtype = "sqlite";
      adminpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
      dbpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
    };
    configureRedis = true;
    maxUploadSize = "16G";
    extraApps = with config.services.nextcloud.package.packages.apps; {
     inherit calendar contacts mail notes onlyoffice tasks;
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    home = "/mnt/Nextcloud-test"
  };

  sops.secrets."Nextcloud/admin/Password" = {};
 
}
