{ pkgs, ... }:

{

  services.jellyfin.enable = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."jellyfin.fschn.org" = {
    forceSSL = true;
    useACMEHost = "fschn.org";
    locations."/" = {
        proxyPass = "127.0.0.1:8096";
        # proxyWebsockets = true;
        # recommendedProxySettings = true;
    };
  };
}
