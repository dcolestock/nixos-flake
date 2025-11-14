{pkgs, ...}: {
  home.packages = with pkgs; [
    fd
    tree
    wget
    curl
    unzip
    delta
    dust
    duf
    procs
    tldr
    poetry
    grc
    lazyjj
    # cargo
    # rustc
  ];

  programs = {
    bat.enable = true;
    eza.enable = true;
    fzf.enable = true;
    jq.enable = true;
    jujutsu.enable = true;
    lazygit.enable = true;
    less.enable = true;
    ripgrep.enable = true;

    # oh-my-posh - starship alternative
    # taskwarrior, taskwarrior-sync
    # command-not-found
    # firefox
    # carapace - command argument completer
    # nix-index
    # skim - command fuzzy finder
    # atuin - bash ctrl+r alternative.  Mcfly?
    # smartcd - autojump, zoxide, pazi, z-lua?

    zellij = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      settings = {
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
            "PLR2004" # Magic value comparison
            "S" # flake8-bandit (security testing)
            "SIM108" # use ternary operators
            "T20" # flake8-print (print statements)
            "TD" # Todo warnings.  Still have basic warning, but no missing author or missing issue warnings
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
