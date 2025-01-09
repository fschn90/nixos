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
}
