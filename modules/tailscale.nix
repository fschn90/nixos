{ pkgs, config, ... }:

{

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
  ];
  services.tailscale.authKeyFile = config.sops.secrets."tailscale/key".path; 

  sops.secrets."tailscale/key" = {
  };

} 
