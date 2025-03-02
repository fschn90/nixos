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
      ../../modules/nginx.nix
      # ../../modules/monitoring/default-server.nix
      # ../../modules/monitoring/default-workstation.nix
      ../../modules/monitoring/prometheus-exporters.nix
      ../../modules/monitoring/promtail.nix
      # ../../modules/home-lab/deluge.nix
      # ../../modules/home-lab/firefox-sync.nix
      # ../../modules/home-lab/immich.nix
      # ../../modules/home-lab/paperless.nix
      # ../../modules/home-lab/syncthing.nix
      # ../../modules/home-lab/fritz.nix
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
    # hostName = hostname;
    hostName = "berry";
    # wireless = {
    #   enable = true;
    #   networks."${SSID}".psk = SSIDpassword;
    #   interfaces = [ interface ];
    # };
  };

  # environment.systemPackages = with pkgs; [ vim ];

  # autologin of user
  services.getty.autologinUser = config.users.users.fschn.name;

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
          proxyPass = "http://100.65.150.91:3000";
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
  networking.firewall.allowedTCPPorts = [ 2222 2223 45849 ];
  networking.firewall.allowedUDPPorts = [ 2222 2223 45849 ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ "tailscale0" ];
    externalInterface = "tailscale0";
    forwardPorts = [
      {
        sourcePort = 2223;
        proto = "tcp";
        destination = "100.114.14.104:8096";
      }
    ];
  };


  # services.nginx.virtualHosts."jellyfin.fschn.org" = {
  # forceSSL = true;
  # useACMEHost = "fschn.org";
  # locations."/" = {
  # proxyPass = "http://localhost:2223";
  # };
  # };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}
