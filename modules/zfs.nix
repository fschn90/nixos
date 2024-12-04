{ lib, pkgs, config, ... }:


let
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (
          (!isUnstable && !kernelPackages.zfs.meta.broken)
          || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
        )
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );

in

{

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  # temp bugfix
  # boot.kernelPackages = pkgs.linuxPackages_6_10;
  ## option depreciated
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.kernelPackages = latestKernelPackage;

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

}
