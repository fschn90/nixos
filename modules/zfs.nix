{ pkgs, config, ... }:

{

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  # temp bugfix
  # boot.kernelPackages = pkgs.linuxPackages_6_10;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

}
