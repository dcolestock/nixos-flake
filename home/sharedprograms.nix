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
    zellij.enable = true;

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

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      delta.enable = true;
      core.editor = "nvim";
      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        merge.tool = "nvimdiff";
        mergetool.nvimdiff = {
          cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
          prompt = false;
        };
      };
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
