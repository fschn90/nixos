{ pkgs, ... }:

{

  home.packages = with pkgs; [
    firefox
    thunderbird
    vlc
    transmission_4-gtk
    spotify
    signal-desktop
    libreoffice
    mumble
    digikam
    viking
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
    filezilla
    gimp-with-plugins
    zellij
    nextcloud-client
    file-roller # Archive manager
    tree
    nh
  ];

}
