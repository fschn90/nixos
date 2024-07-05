{ pkgs, ... }:

{

  programs.gnupg.agent = {
    enable = true; 
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-gnome3 # gnupg dependency to generate pgp key
  ];

}
