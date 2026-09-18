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
      # ./firefox-sync.nix
      ./immich.nix
      ./paperless.nix
      ./syncthing.nix
      ./nginx-reverse-proxies.nix
      ../../modules/overlays.nix
      ./postgresql.nix
      ./arr.nix
    ];

  networking.hostName = "omhe"; # Define your hostname.
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
