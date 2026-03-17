{...}: {
  flake.modules.nixos.packages = {
    pkgs,
    pkgs-master,
    ...
  }: {
    environment.systemPackages = with pkgs; [
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
      dust
      duf
      procs
      tldr
      nodePackages.sql-formatter
      pre-commit
      devenv
      taskwarrior3
      rclone
      tmux
      recapp
      pkgs-master.gemini-cli
      openjdk17
      libgccjit
      poetry
      cabextract
      vlc
      makemkv
      handbrake
      libdvdread
      libdvdnav
      libdvdcss
      keepassxc
      libreoffice
      google-chrome
      chromium
      firefox
      obsidian
      heroic
      mpv
      kdePackages.krfb
      wl-clipboard
      xclip
      xdotool
      newsflash
      virt-manager
      virt-viewer
      qemu
      gparted
      alejandra
      manix
      nh
      pavucontrol
      inotify-tools
      solaar
      (pkgs.symlinkJoin {
        name = "neovide-wrapped";
        paths = [pkgs.neovide];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/neovide --prefix LD_LIBRARY_PATH : ${pkgs.xorg.libX11}/lib
        '';
      })
    ];
    programs = {
      noisetorch.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [proton-ge-bin];
      };
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      git.enable = true;
      wireshark.enable = true;
      kdeconnect.enable = true;
      fish.enable = true;
    };
  };

  flake.modules.homeManager.packages = {pkgs, ...}: {
    home.packages = with pkgs; [fd tree wget curl unzip delta dust duf procs tldr poetry grc lazyjj rustup];
    home.sessionPath = ["$HOME/.cargo/bin"];
    programs = {
      bat.enable = true;
      eza.enable = true;
      fzf.enable = true;
      jq.enable = true;
      jujutsu.enable = true;
      lazygit.enable = true;
      less.enable = true;
      ripgrep.enable = true;
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
          exclude = [".bzr" ".direnv" ".eggs" ".git" ".git-rewrite" ".hg" ".ipynb_checkpoints" ".mypy_cache" ".nox" ".pants.d" ".pyenv" ".pytest_cache" ".pytype" ".ruff_cache" ".svn" ".tox" ".venv" ".vscode" "__pypackages__" "_build" "buck-out" "build" "dist" "node_modules" "site-packages" "venv"];
          lint = {
            per-file-ignores = {"__init__.py" = ["F401"];};
            preview = true;
            select = ["ALL"];
            ignore = ["ANN" "CPY" "D" "DOC" "ERA" "PLR2004" "S" "SIM108" "T20" "TD"];
            fixable = ["ALL"];
            unfixable = [];
            dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
            pydocstyle.convention = "google";
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
  };
}
