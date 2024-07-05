{ config, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    lshw
    htop
    zellij
    nixfmt-classic
    tree
    # alacritty
    # fishPlugins.bobthefish
    # gnomeExtensions.appindicator
    # gnomeExtensions.openweather
    # gnomeExtensions.dash-to-dock
    # gnomeExtensions.clipboard-indicator
    # gnomeExtensions.system-monitor-tray-indicator
    # gnome.adwaita-icon-theme
    lua
    python3
    bash
    docker
    postgresql
    # sops
    # gnupg
    # pinentry-gnome3 # gnupg dependency to generate pgp key
    tailscale
  ];

}


