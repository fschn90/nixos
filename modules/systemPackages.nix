{ config, lib, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    lshw
    htop
    git
    zellij
    nixfmt
    tree
    alacritty
    fishPlugins.bobthefish
    gnomeExtensions.appindicator
    gnomeExtensions.openweather
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.system-monitor-tray-indicator
    gnome.adwaita-icon-theme
    gnomeExtensions.hide-top-bar
    lua
    python3
    # nix
    bash
    docker
    postgresql
    # astronvim dependency
    nerdfonts 
    gcc 
    unzip # for mason
    # tree-sitter 
    wl-clipboard  
    ripgrep
    gdu
    bottom
    nodejs_20
    fd
    sops
    gnupg
    pinentry-gnome # gnupg dependency to generate pgp key
    zlib # python numpy, to get rid of error
  ];

  fonts.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

}


