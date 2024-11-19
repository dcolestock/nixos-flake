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
      extraConfig = {
        core.editor = "nvim";
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
      settings = {
        line-length = 100;
        indent-width = 4;
        target-version = "py312";
        exclude = [
          ".bzr"
          ".direnv"
          ".eggs"
          ".git"
          ".git-rewrite"
          ".hg"
          ".ipynb_checkpoints"
          ".mypy_cache"
          ".nox"
          ".pants.d"
          ".pyenv"
          ".pytest_cache"
          ".pytype"
          ".ruff_cache"
          ".svn"
          ".tox"
          ".venv"
          ".vscode"
          "__pypackages__"
          "_build"
          "buck-out"
          "build"
          "dist"
          "node_modules"
          "site-packages"
          "venv"
        ];
        lint = {
          per-file-ignores = {"__init__.py" = ["F401"];};
          preview = true;
          select = ["ALL"];
          ignore = [
            "ANN" # Annotations
            "CPY" # Copyright
            "D" # pydocstyle (missing docstring)
            "DOC" # pydoclint (more docstring)
            "ERA" # eradicate (commented-out code)
            "S" # flake8-bandit (security testing)
            "T20" # flake8-print (print statements)
          ];
          fixable = ["ALL"];
          unfixable = [];
          dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
          pydocstyle = {
            convention = "google";
          };
        };
        format = {
          quote-style = "double";
          indent-style = "space";
          skip-magic-trailing-comma = false;
          line-ending = "auto";
          docstring-code-format = false;
          docstring-code-line-length = "dynamic";
        };
      };
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
