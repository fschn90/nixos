{ lib, pkgs, ... }:

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


  # sound.enable = true;
  # services.pipewire.enable = lib.mkDefault false;
  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.support32Bit = true; ## If compatibility with 32-bit applications is desired.
  # nixpkgs.config.pulseaudio = true;
  # users.extraUsers.fschn.extraGroups = [ "audio" ];
  # security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/disable-idle-timeout.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              { node.name = "~alsa_input.*" }
              { node.name = "~alsa_output.*" }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
  };


}

