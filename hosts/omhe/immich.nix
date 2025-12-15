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

  systemd.services.nextcloud-autosync = {
    unitConfig = {
      Description = "Auto sync Nextcloud";
      After = "network-online.target";
    };
    script = "${pkgs.nextcloud-client}/bin/nextcloudcmd -h --user $(cat ${config.sops.secrets."Nextcloud/my-user/user".path}) --password $(cat ${config.sops.secrets."Nextcloud/my-user/password".path}) --path /InstantUpload/Camera '/tank/Photos/Phone Pixel 8A/Camera' https://cloud.fschn.org";
    serviceConfig = {
      User = config.users.users.fschn.name;
    };
    wantedBy = [ "multi-user.target" ];
    startAt = "*-*-* *:00:00";
  };

}
