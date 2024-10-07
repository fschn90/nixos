{ pkgs, ... }:

{

  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nil
      nixpkgs-fmt
      nodePackages.prettier
      yaml-language-server
      marksman
      dprint
    ];
    settings = {
      theme = "doom_acario_dark";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        lsp.display-inlay-hints = true;
        mouse = false;
        bufferline = "multiple";
        cursorline = true;
        color-modes = true;
        soft-wrap.enable = true;
        # error msg: Bad config: invalid type: map, expected a boolean ;in `auto-save`
        # auto-save = {
        #   focus-lost = true;
        #   after-delay.enable = true;
        # };
        file-picker = {
          hidden = false;
        };
        statusline = {
          mode.normal = "";
          mode.insert = "I";
          mode.select = "S";
        };
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      keys.normal = {
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
    languages.language = [
      {
        name = "nix";
        language-servers = [ "nil" ];
        auto-format = true;
        formatter.command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
      }
      {
        name = "markdown";
        language-servers = [ "marksman" ];
        auto-format = true;
        formatter.command = "${pkgs.dprint}/bin/dprint";
        formatter.args = [ "fmt" "--stdin" "md" ];
      }
      {
        name = "yaml";
        language-servers = [ "yaml-language-server" ];
        formatter = {
          command = "prettier";
          args = [ "--stdin-filepath" "file.yaml" ];
        };
        auto-format = true;
      }
    ];
  };

  home.packages = with pkgs; [
    lazygit
    yazi # terminal file manager
    wl-clipboard
  ];
}

