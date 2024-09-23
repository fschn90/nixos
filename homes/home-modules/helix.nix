{ pkgs, ... }:

{

  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nil
      yazi # terminal file manager
      lazygit
      nixpkgs-fmt
    ];
    settings = {
      theme = "doom_acario_dark";
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
  };

}
