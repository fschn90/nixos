{ pkgs, config, ... }:

{

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
    "--auth-key=file:${config.sops.secrets."tailscale/key".path}"
  ];
  services.tailscale.authKeyFile = config.sops.secrets."tailscale/key".path; 

  sops.secrets."tailscale/key" = {
    mode = "0400";
    owner = "root";
  };
  
} 
