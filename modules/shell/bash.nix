{config, ...}: let
  shared = config.flake.modules.shared.shell;
in {
  flake.modules.homeManager.bash = {pkgs, ...}: let
    flakePath = shared.flakePath;
  in {
    programs.bash = {
      enable = true;
      historySize = -1;
      historyFileSize = -1;
      shellAliases =
        shared.aliases
        // {
          please = "sudo $(fc -ln -1)";
        };
      bashrcExtra = builtins.readFile ../assets/config/bashrc;
    };
    home.sessionVariables = shared.envVars;
    programs.readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case On
        "\C-H":"\C-W"
        set enable-bracketed-paste off
      '';
    };
    xdg.configFile."autostart/dconfwatch.desktop".source = ../assets/config/dconfwatch.desktop;
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "switchnix";
        runtimeInputs = [nh jujutsu alejandra];
        text = ''
          cd "${flakePath}/"
          alejandra . >/dev/null 2>&1
          nh os switch
          gen=$(readlink /nix/var/nix/profiles/system | grep -oP '\d+')
          [[ -n "$gen" ]] && jj describe -m "Generation $gen"
        '';
      })
      (writeShellApplication {
        name = "switch-trace";
        runtimeInputs = [nh jujutsu alejandra];
        text = ''
          cd "${flakePath}/"
          alejandra . >/dev/null 2>&1
          nh os switch -- --show-trace --option eval-cache false
          gen=$(readlink /nix/var/nix/profiles/system | grep -oP '\d+')
          [[ -n "$gen" ]] && jj describe -m "Generation $gen"
        '';
      })
      (writeShellApplication {
        name = "bootnix";
        runtimeInputs = [nh jujutsu alejandra];
        text = ''
          cd "${flakePath}/"
          alejandra . >/dev/null 2>&1
          nh os boot
          gen=$(readlink /nix/var/nix/profiles/system | grep -oP '\d+')
          [[ -n "$gen" ]] && jj describe -m "Generation $gen (boot required)"
        '';
      })
      (writeShellApplication {
        name = "testnix";
        runtimeInputs = [nh alejandra];
        text = ''
          cd "${flakePath}/"
          alejandra . >/dev/null 2>&1
          nh os test -- --show-trace --option eval-cache false
        '';
      })
      (writeShellApplication {
        name = "update";
        runtimeInputs = [nh jujutsu alejandra];
        text = ''
          cd "${flakePath}/"
          alejandra . >/dev/null 2>&1
          echo "Updating flake..."
          nix flake update
          changes=$(jj status --no-pager 2>/dev/null)
          if echo "$changes" | grep -q "Working copy changes"; then
            echo "Rebuilding..."
            nh os switch
            gen=$(readlink /nix/var/nix/profiles/system | grep -oP '\d+')
            tag=""
            [[ -n "$gen" ]] && tag=" - Generation $gen"
            jj describe -m "Flake update $(date '+%Y.%m.%d')$tag"
          else
            echo "Flake already up to date."
          fi
          echo "Done"
        '';
      })
      (writeShellApplication {
        name = "fzf-preview";
        runtimeInputs = [tree file bat catimg];
        text = builtins.readFile ../assets/scripts/fzf-preview.sh;
      })
      (writeShellApplication {
        name = "rfv";
        runtimeInputs = [fzf ripgrep bat];
        text = builtins.readFile ../assets/scripts/rfv.sh;
      })
      (writers.writePython3Bin "dconfwatch" {} (builtins.readFile ../assets/scripts/dconfwatch.py))
      (writers.writePython3Bin "sqlparser" {
        libraries = [pkgs.python3Packages.sqlparse];
      } (builtins.readFile ../assets/scripts/sqlparser.py))
      (writeShellApplication {
        name = "ee";
        runtimeInputs = [fzf];
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
      (writeShellApplication {
        name = "remind";
        runtimeInputs = [pkgs.notify-desktop];
        text = ''
          # Check if at least two arguments are provided
          if [ $# -lt 2 ]; then
            echo "Usage: $0 <time><s/m> <message>"
            echo "Example: $0 5m 'Take a break!' or $0 30s 'Check the oven!'"
            exit 1
          fi

          # Extract the delay and message
          TIME_INPUT=$1
          shift
          MESSAGE="$*"

          # Check if the input ends with 's' or 'm'
          if [[ $TIME_INPUT =~ ^([0-9]+)([sm])$ ]]; then
            TIME_VALUE=''${BASH_REMATCH[1]}
            TIME_UNIT=''${BASH_REMATCH[2]}

            # Convert to seconds
            if [ "$TIME_UNIT" == "m" ]; then
              DELAY_SECONDS=$((TIME_VALUE * 60))
            else
              DELAY_SECONDS=$TIME_VALUE
            fi
          else
            echo "Invalid time format. Use a number followed by 's' (seconds) or 'm' (minutes)."
            exit 1
          fi

          # Schedule the notification
          (sleep "$DELAY_SECONDS" && notify-desktop -t 0 "Reminder" "$MESSAGE") >/dev/null 2>&1 &
          disown

          echo "Reminder set for $TIME_INPUT."
        '';
      })
    ];
  };
}
