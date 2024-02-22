{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./tmux.nix
    ./starship.nix
    ./neovim.nix
    ./python.nix
  ];
  home.username = "dcolest";
  home.homeDirectory = "/home/dcolest";

  home.packages = with pkgs; [
    tmux
    eza
    bat
    fd
    fzf
    ripgrep
    tree
    wget
    curl
    unzip
    jq
    delta
    du-dust
    duf
    procs
    tldr
    nodePackages.pyright
    nodePackages.sql-formatter
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.ruff = {
    enable = true;
    settings = {};
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
