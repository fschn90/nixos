{ config, lib, pkgs, ... }:

{

  networking.firewall = {
    allowedUDPPorts =
      [ 51820 ]; # Clients and peers can use the same port, see listenport
  };
  networking.firewall.checkReversePath = false;
  networking.wireguard.enable = true;
  
} 
