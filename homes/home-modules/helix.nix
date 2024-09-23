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
        lsp.display-inlay-hints = true;
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [{
      name = "nix";
      language-servers = [ "nil" ];
      auto-format = true;
      formatter.command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
    }];
  };

}
