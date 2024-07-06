{ pkgs, ... }:

{

  home.packages = with pkgs; [
    fishPlugins.bobthefish
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g theme_color_scheme solarized-dark
    '';
  };

  programs.git = {
    enable = true;
    userName = "fschn90";
    userEmail = "hello@fschn.org";
    extraConfig = { init.defaultBranch = "main"; };
  };
}
