{ config, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    lshw
    htop
    nixfmt-classic
    tree
    lua
    python3
    bash
    docker
    postgresql
  ];

}


