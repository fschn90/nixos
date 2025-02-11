{ config, pkgs, ... }:
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


  ### nextcloud sync for photos on phone to be automatically added to immich in the background

  sops.secrets."Nextcloud/my-user/user" = {
    owner = config.users.users.fschn.name;
    mode = "0400";
  };
  sops.secrets."Nextcloud/my-user/password" = {
    owner = config.users.users.fschn.name;
    mode = "0400";
  };

  environment.systemPackages = with pkgs; [
    nextcloud-client
  ];

  home-manager.users.fschn = {
    systemd.user = {
      services.nextcloud-autosync = {
        Unit = {
          Description = "Auto sync Nextcloud";
          After = "network-online.target";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h --user $(cat ${toString config.sops.secrets."Nextcloud/my-user/user".path}) --password $(cat ${toString config.sops.secrets."Nextcloud/my-user/password".path}) --path /InstantUpload/OpenCamera '/tank/Photos/Phone Pixel 8A/OpenCamera' https://cloud.fschn.org";
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
