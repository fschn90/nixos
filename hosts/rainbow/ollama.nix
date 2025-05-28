{ pkgs, ... }:
{

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    package = pkgs.unstable.ollama;
    # environmentVariables = {
    # HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
    # };
    rocmOverrideGfx = "11.0.1";
    loadModels = [ "gemma3:12b-it-q8_0" "llama3.1:latest" "deepseek-r1:14b" ];
  };

  services.open-webui.enable = true;
  services.open-webui.host = "100.114.14.104";

}
