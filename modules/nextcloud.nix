{ pkgs, config, lib, ... }:

{

  services.nextcloud = {
    enable = true;
    hostName = "cloud.fschn.org";
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql"; # nextcloud is not optimised for sqlite thus pgsql
      adminuser = "fschn"; 
      adminpassFile = config.sops.secrets."Nextcloud/admin/Password".path;
    };
    configureRedis = true; # for caching
    maxUploadSize = "16G"; # bigger file size for eg movies
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts notes onlyoffice tasks 
        deck maps phonetrack polls;
        # cospend throws errors
        # works but dont use:
        # mail bookmarks polls cookbook music
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
    ensureUsers = {
      nextcloud-exporter = {
        email = "nextcloud-exporter@localhost";
        passwordFile = config.sops.secrets."Nextcloud/exporter/Password".path;
      };
    };
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
 
  services.prometheus.exporters.nextcloud.enable = true;
  # services.prometheus.exporters.nextcloud.listenAddress = "localhost";
  services.prometheus.exporters.nextcloud.passwordFile = config.sops.secrets."Nextcloud/exporter/Password".path;
  services.prometheus.exporters.nextcloud.url = "https://${builtins.toString config.services.nextcloud.hostName}"; 
  # services.prometheus.exporters.nextcloud.extraFlags = [
  #   "--tls-skip-verify true"
  # ];

  sops.secrets."Nextcloud/exporter/Password" = {
    path = "/tank/Nextcloud/Exporter-Password";
    owner = "nextcloud";
    mode = "0440";
  };

  imports = [
    "${fetchTarball {
    url = "https://github.com/onny/nixos-nextcloud-testumgebung/archive/fa6f062830b4bc3cedb9694c1dbf01d5fdf775ac.tar.gz";
    sha256 = "0gzd0276b8da3ykapgqks2zhsqdv4jjvbv97dsxg0hgrhb74z0fs";}}/nextcloud-extras.nix"
  ];

  users.users.nextcloud-exporter.extraGroups = [ "nextcloud" ];

}


