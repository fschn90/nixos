# your home manager configuration
{
  imports = [
   # ./git.nix
   # ./i3.nix
   ./packages.nix
   ../home-modules/nvim.nix
   ../home-modules/alacritty.nix
   ../home-modules/dconf.nix
   ../home-modules/fish.nix
   ../home-modules/git.nix
   ../home-modules/zoxide.nix
   # ./taskwarrior.nix
  ];

  home.username = "fschn";
  home.homeDirectory = "/home/fschn";

  home.stateVersion = "23.11";
  
}
