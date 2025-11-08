{ pkgs, config, ... }:
{

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    package = pkgs.unstable.ollama;
    # environmentVariables = {
    # HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
    # };
    rocmOverrideGfx = "11.0.1";
    loadModels = [ "gemma3:12b-it-q8_0" ];
    host = "0.0.0.0";
  };

  # avoiding Error: listen tcp 100.114.14.104:11434: bind: cannot assign requested address 
  systemd.services."ollama" = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
  };

}
