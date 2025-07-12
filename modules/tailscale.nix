{ pkgs, config, lib, ... }:

{


  sops.secrets."tailnet/omhe" = { };

  options = {
    tailnet = {
      berry = lib.mkOption {
        type = lib.types.str;
        default = "100.65.150.91";
      };
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
