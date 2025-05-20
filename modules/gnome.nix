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

  # auto login user at boot up
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "fschn";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # tweaks 
  services.gnome.core-apps.enable = false;
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  # hardware.pulseaudio.enable = false;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]);

  # gnome extentions
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    # gnomeExtensions.openweather
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.system-monitor-tray-indicator
    adwaita-icon-theme
  ];

  # making sure the keyring auto unlocks at boot up, needed for protonmail-bridge and nextcloud-client
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  programs.seahorse.enable = true; # installing gui 



}
