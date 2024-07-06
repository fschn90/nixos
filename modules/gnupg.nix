{ pkgs, ... }:

{

  programs.gnupg.agent = {
    enable = true; 
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  users.users."fschn".packages = with pkgs; [
    gnupg
    pinentry-gnome3
  ];

}
