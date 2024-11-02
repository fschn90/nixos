{

  # sound.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa = {
  #     enable = true;
  #     # support32Bit = true;
  #   };
  #   pulse.enable = true;
  #   jack.enable = true;

  #   wireplumber.enable = true;

  # };


  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.
  nixpkgs.config.pulseaudio = true;


}

