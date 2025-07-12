{ pkgs, config, lib, ... }:

{

  options = {
    tailnet = {
      omhe = lib.mkOption {
        type = lib.types.str;
        default = "100.67.133.79";
      };
      rainbow = lib.mkOption {
        type = lib.types.str;
        default = "100.114.14.104";
      };
      berry = lib.mkOption {
        type = lib.types.str;
        default = "100.65.150.91";
      };
      oide = lib.mkOption {
        type = lib.types.str;
        default = "100.79.181.86";
      };
    };
  };

  config = {

    environment.systemPackages = with pkgs; [
      tailscale
    ];

    services.tailscale.enable = true;
    services.tailscale.extraUpFlags = [
      "--ssh"
    ];

    # services.tailscale.authKeyFile = config.sops.secrets."tailscale/key".path; 

    sops.secrets."tailscale/key" = { };

  };

} 
