{ config, ... }:
{

  services.immich = {
    enable = true;
    environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    mediaLocation = "/tank/Immich";
    environment = {
      UPLOAD_LOCATION = "/tank/Immich/upload";
      THUMB_LOCATION = "/tank/Immich/thumbs";
      ENCODED_VIDEO_LOCATION = "/tank/Immich/encoded-video";
      PROFILE_LOCATION = "/tank/Immich/profile";
      BACKUP_LOCATION = "/tank/Immich/backups";
    };
  };

  services.nginx.virtualHosts."photos.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.immich.port}";
    };
  };

  users.users.immich.extraGroups = [ "users" ];


  ### nextcloud sync for photos on phone

  ### DRAFT still need to change everything 

  home-manager.users.myuser = {
    systemd.user = {
      services.nextcloud-autosync = {
        Unit = {
          Description = "Auto sync Nextcloud";
          After = "network-online.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --path /music /home/myuser/music https://nextcloud.example.org";
          TimeoutStopSec = "180";
          KillMode = "process";
          KillSignal = "SIGINT";
        };
        Install.WantedBy = [ "multi-user.target" ];
      };
      timers.nextcloud-autosync = {
        Unit.Description = "Automatic sync files with Nextcloud when booted up after 5 minutes then rerun every 60 minutes";
        Timer.OnBootSec = "5min";
        Timer.OnUnitActiveSec = "60min";
        Install.WantedBy = [ "multi-user.target" "timers.target" ];
      };
      startServices = true;
    };
  };



}
