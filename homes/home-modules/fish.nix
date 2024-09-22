{

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g theme_color_scheme solarized-dark
      if status is-interactive
        eval (zellij setup --generate-auto-start fish | string collect)
      end
      function y
      	set tmp (mktemp -t "yazi-cwd.XXXXXX")
      	yazi $argv --cwd-file="$tmp"
      	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      		builtin cd -- "$cwd"
      	end
      	rm -f -- "$tmp"
      end
    '';
  };

}
