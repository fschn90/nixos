# your home manager configuration
{
  imports = [
   # ./git.nix
   # ./i3.nix
   ./packages.nix
   ../home-modules/nvim.nix
   # ./taskwarrior.nix
  ];

  home.username = "fschn";
  home.homeDirectory = "/home/fschn";

  home.stateVersion = "23.11";
  
}
