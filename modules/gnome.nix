{ config, lib, pkgs, ... }:

{

 # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "fschn";
    gdm.wayland = true;
    gdm.enable = true;
   };


  # necesarry for gnome 
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.gnome.core-utilities.enable = false;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  hardware.pulseaudio.enable = false;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]);

}
