{ pkgs, ... }:

{

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt-classic";
    }];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  home.packages = with pkgs; [ yazi ];

}
