{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ### Language Servers ###
      nodePackages.bash-language-server
      lua-language-server
      # black
      # flake8
      pyright
      nodejs
      # nil
      nixd
      rnix-lsp
      # nixfmt
      # statix - Client crashed when opening .nix file
      # deadnix
      # alejandra
      marksman
      # yamllint
      # nodePackages.diagnostic-languageserver - Causes error when doing lsp format on .nix files
      # nodePackages.markdownlint-cli
      # nodePackages.jsonlint

      lazygit

      # Toolchain for treesitter compilation
      binutils
      gcc_multi
    ];
  };
}
