{ pkgs, ... }:

{

  services.jellyfin.enable = true;
  services.jellyfin.dataDir = "/tank/Jellyfin";
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

  # making sure jellyfin has access to deluge download dir
  users.users.jellyfin.extraGroups = [ "deluge" ];


}
