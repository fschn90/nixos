# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/systemPackages.nix
      ../../modules/wireguard.nix
      ../../modules/ssh.nix
      ../../modules/users.nix
      ../../modules/sops.nix
      ../../modules/tailscale.nix
      ../../modules/sanoid-backup-target.nix
      ../../modules/nix.nix
      ./nextcloud.nix
      ./adguardhome.nix
      ../../modules/acme.nix
      ./jellyfin.nix
      ../../modules/nginx.nix
      ../../modules/monitoring/default-server.nix
      ./deluge.nix
      ./firefox-sync.nix
      ./immich.nix
      ./paperless.nix
      ./syncthing.nix
      ./nginx-reverse-proxies.nix
      # ./tor.nix
      # ./protonmail-bridge.nix
      ../../modules/overlays.nix
      ./open-webui.nix
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.devices = [ "nodev" ];
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.requestEncryptionCredentials = true;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  # services.zfs.autoScrub.enable = true;
  # services.zfs.trim.enable = true;
  # programs.zsh.enable = true;

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "omhe"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostId = "e2990a3c";
  boot.zfs.extraPools = [ "tank" ];
  boot.loader.systemd-boot.enable = true;

  # make sure only NIXROOT credentials are requested, and not other pools as well
  boot.zfs.requestEncryptionCredentials = lib.mkForce [ "NIXROOT" "tank" ];

  # wifi card driver settings to ensure stable connection
  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=8 swcrypto=0 bt_coex_active=0 power_save=0
    options iwlmvm power_scheme=1 
    options iwlwifi uapsd_disable=1 
  '';
  hardware.bluetooth.enable = false;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # autologin of user
  services.getty.autologinUser = config.users.users.fschn.name;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

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

  # fishshell, necessary
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.fschn users {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # #  packages = with pkgs; [
  # #    firefox
  # #     tree
  # #  ];
  # };
  # users.mutableUsers = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 2222 45849 ];
  # networking.firewall.allowedUDPPorts = [ 2222 45849 ];
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
