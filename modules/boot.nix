# {
#
#   boot.loader.grub.enable = true;
#   boot.loader.grub.devices = [ "nodev" ];
#   boot.loader.grub.efiInstallAsRemovable = true;
#   boot.loader.grub.efiSupport = true;
#   boot.loader.grub.useOSProber = true;
#
# }
{
  boot.loader.systemd-boot.enable = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
  };
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.editor = false;
}
