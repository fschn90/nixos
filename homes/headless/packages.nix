{ pkgs, ... }:

{

  home.packages = with pkgs; [
    fishPlugins.bobthefish
    helix
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g theme_color_scheme solarized-dark
    '';
  };

}
