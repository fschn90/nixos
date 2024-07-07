{ pkgs, ... }:

{

  home.packages = with pkgs; [
    firefox
    vlc
    transmission-gtk
    vscode
    google-chrome
    spotify
    signal-desktop 
    libreoffice
    mumble
    fishPlugins.bobthefish
    gnome.gnome-disk-utility
    gnome.dconf-editor
    gnome.nautilus
    gnome.seahorse
    gnome.gnome-calculator
    gnome-decoder # bar- / qr-code scanner
    loupe # image viewer
    snapshot # webcam viewer
    element-desktop
    evince # gnome doc viewer
    gtypist # type tutor, 10-finger-system
    zellij
  ];

}
