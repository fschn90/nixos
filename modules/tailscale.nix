{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
  ];
  
} 
