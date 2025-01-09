{ config, ... }:
{

  services.immich = {
    enable = true;
    environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    mediaLocation = "/tank/Immich";
  };

  services.nginx.virtualHosts."photos.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.immich.port}";
    };
  };
}
