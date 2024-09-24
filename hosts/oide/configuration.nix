# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./t490-nvidia.nix
    # ../../modules/boot.nix
    ../../modules/sound.nix
    ../../modules/bluetooth.nix
    ../../modules/zfs.nix
    ../../modules/gnome.nix
    ../../modules/users.nix
    ../../modules/systemPackages.nix
    ../../modules/wireguard.nix
    ../../modules/steam.nix
    ../../modules/gnupg.nix
    ../../modules/sops.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
    ../../modules/nix.nix
    # ../../modules/prometheus-exporters.nix
    # ../../modules/promtail.nix
    # ../../modules/scrutiny.nix
    ../../modules/nginx.nix
    ../../modules/acme.nix
    ../../modules/monitoring/default-workstation.nix
    ../../modules/sanoid-backup-source.nix
  ];

  # necessary for zfs
  networking.hostId = "8425e349";

  networking.hostName = "oide"; # Define your hostname.

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  boot.loader.systemd-boot.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # 20.09.2024 to avoid https://discourse.nixos.org/t/unable-to-build-nix-due-to-nvidia-drivers-due-or-kernel-6-10/49266/1
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "555.58.02";
    sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
    sha256_aarch64 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
    openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
    settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
    persistencedSha256 = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
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

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # fishshell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # PROGRAMS NEED SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.settings.PasswordAuthentication = false;
  # services.openssh.settings.PermitRootLogin = "no";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether. 
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

