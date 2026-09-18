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
      ./tor.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
    hostName = "helio";
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

  # fishshell, necessary
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # networking.firewall.allowedTCPPorts = [ 2223 ];
  # networking.firewall.allowedUDPPorts = [ 2223 ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
