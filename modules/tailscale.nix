{ pkgs, config, lib, ... }:

{

  options = {
    tailscale.clients.omhe.ip = lib.mkOption {
      type = lib.types.str;
      default = "100.106.245.44";
      # add description and use builin.readFile to link to new ip, deployed via sops-nix
    };
  };

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
  ];
#   services.tailscale.authKeyFile = config.sops.secrets."tailscale/key".path; 

  sops.secrets."tailscale/key" = {
  };

} 
