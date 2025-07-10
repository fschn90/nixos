{ pkgs, config, lib, ... }:

{


  sops.secrets."tailnet/omhe" = { };

  options = {
    tailnet.omhe.ip = lib.mkOption {
      type = lib.types.str;
      default = builtins.readFile config.sops.secrets."tailnet/omhe".path;
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

  sops.secrets."tailscale/key" = { };

} 
