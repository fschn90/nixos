 {pkgs, ...}: 

  {
  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.protonmail-bridge = {          
  description = "Protonmail Bridge";          
  enable = true;          
  preStart = "sleep 10";
  script = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive --log-level info";          
  path = [ pkgs.gnome3.gnome-keyring ]; # HACK: https://github.com/ProtonMail/proton-bridge/issues/176          
  wantedBy = [ "graphical-session.target" ];          
  partOf = [ "graphical-session.target" ];        };
  }
