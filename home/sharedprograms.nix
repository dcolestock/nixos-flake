{pkgs, ...}: {
  home.packages = with pkgs; [
    fd
    tree
    wget
    curl
    unzip
    delta
    du-dust
    duf
    procs
    tldr
    poetry
  ];

  programs = {
    bat.enable = true;
    eza.enable = true;
    fzf.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;

    # oh-my-posh - starship alternative
    # taskwarrior, taskwarrior-sync
    # command-not-found
    # firefox
    # lazygit
    # carapace - command argument completer
    # nix-index
    # skim - command fuzzy finder
    # atuin - bash ctrl+r alternative.  Mcfly?
    # smartcd - autojump, zoxide, pazi, z-lua?
    # zellij - tmux alternative
    git = {
      enable = true;
      delta.enable = true;
    };
    ruff = {
      enable = true;
      settings = {};
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.warn_timeout = "5m";
    };
  };

  manual.html.enable = true;
  manual.json.enable = true;
}
