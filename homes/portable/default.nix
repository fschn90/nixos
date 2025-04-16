# your home manager configuration
{
  imports = [
    ./packages.nix
    # ../home-modules/packages.nix
    # ../home-modules/nvim.nix
    ../home-modules/alacritty.nix
    ../home-modules/dconf.nix
    ../home-modules/fish.nix
    ../home-modules/git.nix
    ../home-modules/zoxide.nix
    ../home-modules/helix.nix
  ];

  home.username = "fschn";
  home.homeDirectory = "/home/fschn";

  home.stateVersion = "23.11";

}
