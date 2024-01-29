# { inputs, outputs, lib, config, pkgs, ... }:q
{ pkgs, lib, ... }:

{
  # packages I like to be insalled
  home.packages = with pkgs; [
    firefox
    thunderbird
    vlc
    keepassxc
    transmission-gtk
    vscode
    google-chrome
    spotify
    signal-desktop
    libreoffice
    mumble
    digikam
    viking
    gnome.gnome-disk-utility
    gnome.nautilus
    gnome-decoder
    loupe
    snapshot
    element-desktop
    evince
    gtypist
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true; 
  };

  #xdg.configFile.nvim = {
  #  source = ./nvim;
  #  recursive = true;
  #};

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -g theme_color_scheme solarized-dark
      if status is-interactive
        eval (zellij setup --generate-auto-start fish | string collect)
      end
      set -x PATH $HOME/.emacs.d/bin $PATH 
    '';
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/interface".show-battery-percentage = true;
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Primary><Alt>t";
          command = "alacritty";
          name = "open-terminal";
        };

      "org/gnome/shell".enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "system-monitor-indicator@mknap.com"
        "System_Monitor@bghome.gmail.com"
        "openweather-extension@jenslody.de"
        "dash-to-dock@micxgx.gmail.com"
        "clipboard-indicator@tudmotu.com"
        "hidetopbar@mathieu.bidon.ca"
      ];

    };
  };

  programs.git = {
    enable = true;
    userName = "flo-schn";
    userEmail = "hello@fschn.org";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".ssh" = {
    enable = true; 
    source = ./ssh;
    recursive = true;
  };

}
