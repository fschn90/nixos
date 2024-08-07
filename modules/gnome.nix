{ pkgs, ... }:

{

 # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager = {
    gdm.wayland = true;
    gdm.enable = true;
   };
   services.displayManager.autoLogin.enable = true;
   services.displayManager.autoLogin.user = "fschn";

  # necesarry for gnome 
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.gnome.core-utilities.enable = false;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  hardware.pulseaudio.enable = false;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]);

  # gnome extentions
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.openweather
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.system-monitor-tray-indicator
    gnome.adwaita-icon-theme
  ];

}
