{ pkgs, ... }:

{

  services.jellyfin.enable = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  # services.nginx.virtualHosts."jellyfin.fschn.org" = {
  #   forceSSL = true;
  #   useACMEHost = "fschn.org";
  #   locations."/" = {
  #       proxyPass = "100.106.245.44:8096";
  #       recommendedProxySettings = true;
  #   };
  # };
}
