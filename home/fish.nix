{pkgs, ...}: {
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      {
        name = "autopair";
        src = autopair.src;
      }
      {
        name = "colored-man_pages";
        src = colored-man-pages.src;
      }
      {
        name = "done";
        src = done.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "fish-you-should-use";
        src = fish-you-should-use.src;
      }
    ];
    shellAbbrs = {
      c = "cd";
      ".." = "cd ..";
      "..." = "cd ../..";
      l = "ls";

      diff = "delta";
      # cat = "bat";
      du = "dust --limit-filesystem";
      df = "duf";
      ps = "procs";
      fd = "fd --mount";
      rg = "rg --one-file-system";

      less = "less -r"; # raw control characters
      where = "type -a";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";

      untar = "tar -xvaf";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      sudoedit = "command sudo -E nvim";
      nvim = "nvim -w ~/.nvimkeystrokes";
      myvim = "NVIM_APPNAME=myvim nvim";

      gd = "git diff";
      gc = "git commit";
      gp = "git add -p";
    };
    shellAliases = {
      path = "printf '%s\n' $PATH";
      please = "eval command sudo $history[1]";
      weather = "curl -sS wttr.in|head -n -2";
      tmux = "direnv exec / tmux -2 new -As0 -c ~";

      ls = "exa --group-directories-first --color=auto --icons=auto";
      ll = "ls -l";
      la = "ls -a ";
      lla = "ls -l -a";
      laa = "lla";
      lt = "ls -l -s=modified";

      open = "xdg-open";
      ping = "ping -c 5";
      mkdir = "mkdir -pv";
      wget = "wget -c";
      chmod = "chmod -c --preserve-root";
      chown = "chown -c --preserve-root";
      chgrp = "chgrp -c --preserve-root";

      cp = "cp --interactive --verbose --recursive --reflink=auto";
      mv = "mv --interactive --verbose";
      ln = "ln --interactive --verbose";
      rm = "rm --verbose --interactive=once --preserve-root=all";

      cpv = "rsync -ah --info=progress2";
      gs = "git status && git diff --stat";
    };
    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
      fish_user_key_bindings = {
        description = "Set custom key bindings";
        body =
          # fish
          ''
            bind \eo __fzf_nixedit__
            bind \eq __fzf_nixedit_ripgrep__
          '';
      };
      mc = {
        description = "Make a directory tree and enter it";
        body =
          # fish
          ''
            mkdir -p $argv[1]; and cd $argv[1]
          '';
      };
      configedit = {
        description = "Edit one or nix config files from ~/nixos/";
        body =
          # fish
          ''
            if test (count $argv) -eq 0
                echo "Usage: configedit <file1> [file2 ...]"
                return 1
            end
            set -l paths (realpath $argv)
            env -C ~/nixos $EDITOR -- $paths
          '';
      };
      configeditline = {
        description = "Edit a specific line in a nix config file from ~/nixos/";
        body =
          # fish
          ''
            if test (count $argv) -lt 2
                echo "Usage: configeditline <line> <file>"
                return 1
            end
            set -l path (realpath $argv[2])
            env -C ~/nixos $EDITOR +$argv[1] -- $path
          '';
      };
      __fzf_nixedit__ = {
        description = "Select nix config files to edit with fzf";
        body =
          # fish
          ''
            set -l cmd "fd --mount --type f --hidden --exclude .git . ~/nixos"
            set -l FZF_DEFAULT_OPTS "
              --multi
              --height=(or $FZF_TMUX_HEIGHT 40%)
              --reverse
              $FZF_DEFAULT_OPTS
              $FZF_CTRL_T_OPTS
              --header='Use Tab to select multiple files'
            "

            set -l selection (eval $cmd | fzf)

            if test (count $selection) -gt 0
                commandline -r "configedit $selection"
                commandline -f execute
            end
          '';
      };
      __fzf_nixedit_ripgrep__ = {
        description = "Select nix config files from ~/nixos with ripgrep and fzf";
        body =
          # fish
          ''
            set -l cmd "rg --column --line-number --no-heading --color=always --smart-case"
            set -l FZF_DEFAULT_OPTS "
              --height=80%
              --reverse
              $FZF_DEFAULT_OPTS
              $FZF_CTRL_T_OPTS
              --bind 'start:reload:$rg_prefix \"\" ~/nixos/'
              --bind 'change:reload:$rg_prefix {q} ~/nixos/|| true'
              --color='hl:-1:underline,hl+:-1:underline:reverse'
              --delimiter=':'
              --preview='bat --color=always {1} --highlight-line {2}'
              --preview-window='up,60%,border-bottom,+{2}+3/3,~3'
              --ansi
              --disabled
            "

            set -l selection (eval $cmd | fzf)

            if test (count $selection) -gt 0
              commandline -r "configeditline $selection"
              commandline -f execute
            end
          '';
      };
    };
  };
}
