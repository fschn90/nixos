# { inputs, outputs, lib, config, pkgs, ... }:q
{ pkgs, inputs, config, lib, ... }:

{
  # packages I like to be insalled
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

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
    gnome.dconf-editor
    gnome.nautilus
    gnome-decoder
    loupe
    snapshot
    element-desktop
    evince
    gtypist
    lazygit # astronvim dependency
    filezilla
    youtube-dl
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "None";
      window.startup_mode = "Maximized";
    };
  };              

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
    ];
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  home.file.".config/nvim/lua/user" = {
    enable = true;
    source = ./nvim-user;
    recursive = true;
  };

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
    userName = "fschn90";
    userEmail = "hello@fschn.org";
    extraConfig = { init.defaultBranch = "main"; };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # home.file.".ssh" = {
  #   enable = true;
  #   source = ./ssh;
  #   recursive = true;
  # };

  sops = {
  defaultSopsFile = ../../secrets/example.yaml;
  defaultSopsFormat = "yaml";
  
  age.keyFile = "/home/fschn/.config/sops/age/keys.txt";
  secrets.example-key = {};
  };
  
  home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''

    /run/current-system/sw/bin/systemctl start --user sops-nix
  '';

  programs.ssh = {
    enable = true;
    matchBlocks = {
      test = {
        hostname = "test";
        user = config.sops.secrets.example-key.path;
        # user = "testi";
      };
    };
  };
}
