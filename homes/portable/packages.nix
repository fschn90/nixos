{ pkgs, ... }:

{

  home.packages = with pkgs; [
    firefox
    vlc
    transmission_4-gtk
    spotify
    signal-desktop
    libreoffice
    hunspell
    hunspellDicts.de-de
    hunspellDicts.de-at
    hunspellDicts.en-us-large
    hunspellDicts.en-gb-large
    hunspellDicts.es-es
    hyphenDicts.en_US # British English
    hyphenDicts.de_DE # German, etc.
    mumble
    fishPlugins.bobthefish
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
    nh
  ];

}
