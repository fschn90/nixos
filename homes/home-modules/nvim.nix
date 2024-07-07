{ pkgs, ... }:

{

  # astronvim dependency
  home.packages = with pkgs; [
    lazygit
    nerdfonts 
    gcc 
    unzip # for mason
    wl-clipboard  
    ripgrep
    gdu
    bottom
    nodejs_20
    fd
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
  
  fonts.fontconfig.enable = true;

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

}
