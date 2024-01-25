{ pkgs
, config
, ...
}: {
  programs.bash = {
    enable = true;
    shellAliases = {
      # Magic to let sudo use my aliases
      # https://unix.stackexchange.com/questions/139231/keep-aliases-when-i-use-sudo-bash
      # sudo = "sudo "; # Removed in favor of sudo function

      c = "cd";
      ".." = "c ..";
      "..." = "c ../..";
      open = "xdg-open";

      cp = "cp --recursive --interactive --verbose --reflink=auto";
      mv = "mv --interactive --verbose";

      # Default to human readable figures
      # df = "df -h";
      # du = "du -had1|sort -h";
      diff = "delta";
      cat = "bat";
      du = "dust";
      df = "duf";
      ps = "procs";
      fd = "fd --mount";
      rg = "rg --one-file-system";

      less = "less -r"; # raw control characters
      where = "type -a";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";

      ls = "ls -h --group-directories-first --color=auto";
      ll = "exa -l --group-directories-first";
      la = "exa --group-directories-first -a -a";
      lla = "ll -a -a";
      lt = "ll -s=modified";

      tmux = "tmux -2 new -As0 -c ~";
      untar = "tar -xvaf";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      sudoedit = "command sudo -E vim";
      myvim = "NVIM_APPNAME=myvim nvim";
    };
    sessionVariables = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
      # Wayland Support
      NIXOS_OZONE_WL = "1";

      # Setting fd as the default source for fzf
      FZF_DEFAULT_COMMAND = "fd --mount --type f --strip-cwd-prefix --hidden --exclude .git";
      FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
      FZF_DEFAULT_OPTS = "--color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'";

      # Preview file content using bat (https://github.com/sharkdp/bat)
      FZF_CTRL_T_OPTS = "--preview 'fzf-preview {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'";

      # Print tree structure in the preview window
      FZF_ALT_C_OPTS = "--preview 'tree -C {}'";

      # Stops fzf_tmux, because you can't change windows when this is up
      FZF_TMUX_OPTS = "";
      FZF_TMUX = 0;

      MANPAGER = "sh -c 'col -bx | bat -l man --style=plain --paging always'";
      MANROFFOPT = "-c";
    };
    bashrcExtra = ''
      ${builtins.readFile ./config/bashrc}
    '';
  };
  programs.readline = {
    enable = true;
    extraConfig = ''
      set completion-ignore-case On

      # https://askubuntu.com/questions/701824/getting-ctrl-backspace-to-delete-words-in-gnome-terminal-and-vim-insert-mo
      # Allows ctrl+backspace to delete words in bash vim insert mode
      "\C-H":"\C-W"
    '';
  };
  # programs.mcfly = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };
  xdg.configFile."autostart/dconfwatch.desktop".source = ./config/dconfwatch.desktop;
  home.packages = with pkgs; [

    (writeShellApplication {
      name = "switch";
      text = ''
        cd /home/dan/Projects/dancolestock/nixos/
        gitstatus=$(git status --porcelain)
        if [[ -n "$gitstatus" ]] ; then
          echo "Flake's git not clean.  Aborting."
          exit 1
        fi
        sudo nixos-rebuild switch --flake .
      '';
    })

    (writeShellApplication {
      name = "switch-trace";
      text = ''
        cd /home/dan/Projects/dancolestock/nixos/
        gitstatus=$(git status --porcelain)
        if [[ -n "$gitstatus" ]] ; then
          echo "Flake's git not clean.  Aborting."
          exit 1
        fi
        sudo nixos-rebuild switch --show-trace --option eval-cache false --flake .
      '';
    })

    (writeShellApplication {
      name = "testnix";
      text = ''
        cd /home/dan/Projects/dancolestock/nixos/
        sudo nixos-rebuild test --option eval-cache false --flake .
      '';
    })

    (writeShellApplication {
      name = "update";
      text = ''
        cd /home/dan/Projects/dancolestock/nixos/
        echo "Checking current git status..."
        gitstatus=$(git status --porcelain)
        if [[ -n "$gitstatus" ]] ; then
          echo "Flake's git not clean.  Aborting."
          exit 1
        fi
        echo "Updating flake..."
        nix flake update
        echo "Checking new git status..."
        gitstatus=$(git status --porcelain)
        if [[ -z "$gitstatus" ]] ; then
          echo "Flake already up to date."
          exit 0
        fi
        echo "Committing changes..."
        git commit -am "Flake update $(date '+%Y.%m.%d')"
        echo "Rebuilding..."
        sudo nixos-rebuild switch --flake .
        echo "Done"
      '';
    })

    (writeShellApplication {
      name = "fzf-preview";
      runtimeInputs = [ tree file bat catimg ];
      text = ''
        ${builtins.readFile ./scripts/fzf-preview.sh}
      '';
    })

    (writeShellApplication {
      name = "rfv";
      runtimeInputs = [ fzf ripgrep bat ];
      text = builtins.readFile ./scripts/rfv.sh;
    })

    (writers.writePython3Bin "dconfwatch" { } (builtins.readFile ./scripts/dconfwatch.py))

    (writers.writePython3Bin "sqlparser" {
      libraries = [ pkgs.python3Packages.sqlparse ];
    } (builtins.readFile ./scripts/sqlparser.py))

    (writeShellApplication {
      name = "ee";
      runtimeInputs = [ fzf ];
      text = ''
        set -x
        exec nvim "$(fzf)"
      '';
    })

    (writeShellApplication {
      name = "btconnect";
      text = ''
        MAC=$(bluetoothctl devices | grep "$1" | cut -d ' ' -f 2)
        bluetoothctl connect "$MAC"
      '';
    })

    (writeShellApplication {
      name = "btdisconnect";
      text = ''
        MAC=$(bluetoothctl devices | grep "$1" | cut -d ' ' -f 2)
        bluetoothctl disconnect "$MAC"
      '';
    })

    (writeShellApplication {
      name = "headset";
      text = ''
        btdisconnect Flip
        btconnect WH-CH710N
      '';
    })

    (writeShellApplication {
      name = "speaker";
      text = ''
        btdisconnect WH-CH710N
        btconnect Flip
      '';
    })

  ];
}
