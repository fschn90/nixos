# your home manager configuration
{
  imports = [
   # ./git.nix
   # ./i3.nix
   ./packages.nix
   # ./ssh.nix
   # ./protonmail-bridge.nix
   # ./taskwarrior.nix
  ];

  home.username = "fschn";
  home.homeDirectory = "/home/fschn";

  home.stateVersion = "23.11";
  
}
