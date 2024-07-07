{

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g theme_color_scheme solarized-dark
      if status is-interactive
        eval (zellij setup --generate-auto-start fish | string collect)
      end
    '';
  };

}
