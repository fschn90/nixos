{ pkgs, ... }:

{

  services.jellyfin.enable = true;
  services.jellyfin.dataDir = "/tank/Jellygin";
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."jellyfin.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
      proxyPass = "http://localhost:8096";
    };
  };
}
