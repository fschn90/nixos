{ pkgs, ... }:

{

  home.packages = with pkgs; [
    firefox
    thunderbird
    vlc
    transmission-gtk
    # vscode
    # google-chrome
    spotify
    signal-desktop
    libreoffice
    mumble
    digikam
    viking
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
    filezilla
    protonmail-bridge
    gimp-with-plugins
    zellij
    nextcloud-client
    # zip
    gnome.file-roller # Archive manager
  ];

}
