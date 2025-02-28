{

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
    };
    rocmOverrideGfx = "11.0.1";
  };

  services.open-webui.enable = true;
  services.open-webui.host = "100.114.14.104";

}
