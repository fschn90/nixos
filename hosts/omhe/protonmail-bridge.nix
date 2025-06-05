{ pkgs, ... }:

{
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.gdm.enableGnomeKeyring = true;
  # programs.seahorse.enable = true;

  systemd.user.services.protonmail-bridge = {
    description = "Protonmail Bridge";
    enable = true;
    script = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive --log-level info";
    path = [ pkgs.pass ]; # HACK: https://github.com/ProtonMail/proton-bridge/issues/176          
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.Restart = "always";
  };

  environment.systemPackages = with pkgs; [
    pass
    protonmail-bridge
  ];
}
