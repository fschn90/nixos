{ pkgs, ... }:

{

  home.packages = with pkgs; [
    firefox
    vlc
    transmission-gtk
    spotify
    signal-desktop
    libreoffice
    mumble
    fishPlugins.bobthefish
    gnome-disk-utility
    dconf-editor
    nautilus
    seahorse
    gnome-calculator
    gnome-disk-utility
    dconf-editor
    nautilus
    seahorse
    gnome-calculator
    gnome-decoder # bar- / qr-code scanner
    loupe # image viewer
    snapshot # webcam viewer
    element-desktop
    evince # gnome doc viewer
    gtypist # type tutor, 10-finger-system 
    zellij
    file-roller # Archive manager
    tree
  ];

}
