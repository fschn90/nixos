{ config, lib, pkgs, ... }:

{

  programs.gnupg.agent = {
    enable = true; 
    enableSSHSupport = true;
    # pinentryFlavor = "gnome3";
    # pinentryPackage = "gnome3";
};
}
