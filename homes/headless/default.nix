# your home manager configuration
{
  imports = [
   ./packages.nix
   ../home-modules/nvim.nix
   ../home-modules/git.nix
   ../home-modules/zoxide.nix
  ];

  home.username = "fschn";
  home.homeDirectory = "/home/fschn";

  home.stateVersion = "23.11";
  
}
