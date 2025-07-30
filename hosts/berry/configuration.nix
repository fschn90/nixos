{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/wireguard.nix
      ../../modules/ssh.nix
      ../../modules/users.nix
      ../../modules/sops.nix
      ../../modules/tailscale.nix
      ../../modules/nix.nix
      ./adguardhome.nix
      ../../modules/acme.nix
      ../../modules/nginx.nix
      ../../modules/monitoring/prometheus-exporters.nix
      ../../modules/monitoring/promtail.nix
      ./tor.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "berry";
  };

  time.timeZone = "Europe/Vienna";

  # autologin of user
  services.getty.autologinUser = config.users.users.fschn.name;

  services.openssh.enable = true;

  # allow unfree
  nixpkgs.config.allowUnfree = true;

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # auto upgrade but not auto reboot
  system.autoUpgrade.enable = true;

  # fishshell, necessary
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.nginx = {
    virtualHosts = {
      "fritzbox-eltern.fschn.org" = {
        useACMEHost = "fschn.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.178.1";
        };
      };
      "adguard-eltern.fschn.org" = {
        useACMEHost = "fschn.org";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${toString config.tailnet.berry}:3000";
        };
      };
      "jellyfin.fschn.org" = {
        forceSSL = true;
        useACMEHost = "fschn.org";
        locations."/" = {
          proxyPass = "http://localhost:2223";
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 53 2222 2223 45849 ];
  networking.firewall.allowedUDPPorts = [ 53 2222 2223 45849 ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
