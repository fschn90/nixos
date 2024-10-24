{ pkgs, ... }:
{

  # ONY IN UNSTABLE FOR NOW ... 

  # services.immich = {
  #   enable = true;
  #   environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
  # };

  # users.users.immich.extraGroups = [ "video" "render" ];

  #  error: The option `hardware.graphics' does not exist. Definition values:
  # hardware.graphics = {
  #   # hardware.opengl in 24.05 and older 
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
  #     intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
  #   ];
  # };


  # services.nginx.virtualHosts."photos.fschn.org" = {
  #   forceSSL = true;
  #   useACMEHost = "fschn.org";
  #   locations."/" = {
  #     proxyPass = "http://localhost:3001";
  #   };
  # };
}
