{config, ...}: let
  shared = config.flake.modules.shared.shell;
in {
  flake.modules.homeManager.fish = {pkgs, ...}: let
  in {
    programs.fish = {
      enable = true;
      shellAliases = shared.aliases;
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
      binds = {
        "\\eo".command = "__fzf_nixedit_ripgrep__";
        "\\ee".command = "__fzf_nixedit__";
      };
      functions = {
        fish_greeting.body = "";
        mc.body = "mkdir -p $argv[1]; and cd $argv[1]";
        configedit.body = ''
          if test (count $argv) -eq 0
            echo "Usage: configedit <file1> [file2 ...]"
            return 1
          end
          set -l paths (realpath $argv)
          env -C ${shared.envVars.NH_FLAKE} $EDITOR -- $paths
        '';
        configeditline.body = ''
          if test (count $argv) -lt 2
            echo "Usage: configeditline <line> <file>"
            return 1
          end
          set -l path (realpath $argv[2])
          env -C ${shared.envVars.NH_FLAKE} $EDITOR +$argv[1] -- $path
        '';
        __fzf_nixedit__.body = ''
          set -l cmd "fd --mount --type f --hidden --exclude .git . ${shared.envVars.NH_FLAKE}"
          set -lx FZF_DEFAULT_OPTS "
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
        __fzf_nixedit_ripgrep__.body = ''
          set -l rg_prefix "rg --column --line-number --no-heading --color=always --smart-case"
          set -lx FZF_DEFAULT_OPTS "
            --height=80%
            --reverse
            $FZF_DEFAULT_OPTS
            $FZF_CTRL_T_OPTS
            --bind 'start:reload:$rg_prefix \"\" ${shared.envVars.NH_FLAKE}/'
            --bind 'change:reload:$rg_prefix {q} ${shared.envVars.NH_FLAKE}/ || true'
            --color='hl:-1:underline,hl+:-1:underline:reverse'
            --delimiter=':'
            --preview='bat --color=always {1} --highlight-line {2}'
            --preview-window='up,60%,border-bottom,+{2}+3/3,~3'
            --ansi
            --disabled
          "

          set -l selection (fzf < /dev/null)

          if test (count $selection) -gt 0
            set -l file (echo $selection | cut -d: -f1)
            set -l line (echo $selection | cut -d: -f2)
            commandline -r "configeditline $line $file"
            commandline -f execute
          end
        '';
      };
    };
    home.sessionVariables = shared.envVars;
  };
}
