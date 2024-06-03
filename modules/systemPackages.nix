{ config, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    lshw
    htop
    git
    zellij
    nixfmt-classic
    tree
    alacritty
    fishPlugins.bobthefish
    gnomeExtensions.appindicator
    gnomeExtensions.openweather
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.system-monitor-tray-indicator
    gnome.adwaita-icon-theme
    lua
    python3
    bash
    docker
    postgresql
    # astronvim dependency
    nerdfonts 
    gcc 
    unzip # for mason
    wl-clipboard  
    ripgrep
    gdu
    bottom
    nodejs_20
    fd
    sops
    gnupg
    pinentry-gnome3 # gnupg dependency to generate pgp key
  ];

  fonts.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

}


