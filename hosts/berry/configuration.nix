{ config, pkgs, lib, ... }:

# let
#   # user = "guest";
#   # password = "guest";
#   # SSID = "mywifi";
#   # SSIDpassword = "mypassword";
#   # interface = "wlan0";
#   # hostname = "myhostname";
# in {
{


  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ../../modules/systemPackages.nix
      ../../modules/wireguard.nix
      ../../modules/ssh.nix
      ../../modules/users.nix
      ../../modules/sops.nix
      ../../modules/tailscale.nix
      # ../../modules/sanoid-backup-target.nix
      ../../modules/nix.nix
      # ../../modules/home-lab/nextcloud.nix
      ./adguardhome.nix
      # ../../modules/acme.nix
      # ../../modules/home-lab/jellyfin.nix
      # ../../modules/nginx.nix
      # ../../modules/monitoring/default-server.nix
      ../../modules/monitoring/default-workstation.nix
      # ../../modules/home-lab/deluge.nix
      # ../../modules/home-lab/firefox-sync.nix
      # ../../modules/home-lab/immich.nix
      # ../../modules/home-lab/paperless.nix
      # ../../modules/home-lab/syncthing.nix
      # ../../modules/home-lab/fritz.nix
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
    # hostName = hostname;
    hostName = "berry";
    # wireless = {
    #   enable = true;
    #   networks."${SSID}".psk = SSIDpassword;
    #   interfaces = [ interface ];
    # };
  };

  # environment.systemPackages = with pkgs; [ vim ];

  services.openssh.enable = true;

  # users = {
  #   mutableUsers = false;
  #   users."${user}" = {
  #     isNormalUser = true;
  #     password = password;
  #     extraGroups = [ "wheel" ];
  #   };
  # };

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

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
