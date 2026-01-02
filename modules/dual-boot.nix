{ pkgs, ... }:

{

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.theme = "${pkgs.catppuccin-grub}";
  boot.loader.grub.gfxmodeEfi = "3840x2160";
}

