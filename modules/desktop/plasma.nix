{lib, ...}: {
  flake.modules.nixos.plasma = {
    pkgs,
    lib,
    ...
  }: {
    nixpkgs.overlays = lib.singleton (final: prev: {
      kdePackages =
        prev.kdePackages
        // {
          plasma-workspace = let
            basePkg = prev.kdePackages.plasma-workspace;
            xdgdataPkg = pkgs.stdenv.mkDerivation {
              name = "${basePkg.name}-xdgdata";
              buildInputs = [basePkg];
              dontUnpack = true;
              dontFixup = true;
              dontWrapQtApps = true;
              installPhase = ''
                mkdir -p $out/share
                (
                  IFS=:
                  for DIR in $XDG_DATA_DIRS; do
                    if [[ -d "$DIR" ]]; then
                      cp -r $DIR/. $out/share/
                      chmod -R u+w $out/share
                    fi
                  done
                )
              '';
            };
            derivedPkg = basePkg.overrideAttrs {
              preFixup = ''
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index + 0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index + 1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index + 0))]"
                    unset -v "qtWrapperArgs[$((index + 1))]"
                    unset -v "qtWrapperArgs[$((index + 2))]"
                    unset -v "qtWrapperArgs[$((index + 3))]"
                  fi
                done
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
            };
          in
            derivedPkg;
        };
    });
  };

  flake.modules.homeManager.plasma = {...}: {
    dconf.settings = {
      "org/gnome/shell" = {
        disabled-extensions = [];
        enabled-extensions = ["dash-to-panel@jderose9.github.com" "appindicatorsupport@rgcjonas.gmail.com" "just-perfection-desktop@just-perfection"];
        favorite-apps = ["google-chrome.desktop" "kitty.desktop" "discord.desktop" "steam.desktop" "org.gnome.Nautilus.desktop" "org.keepassxc.KeePassXC.desktop" "obsidian.desktop"];
      };
      "org/gnome/shell/extensions/dash-to-panel" = {
        multi-monitors = false;
        animate-appicon-hover = true;
        dot-style-focused = "SEGMENTED";
        dot-style-unfocused = "SEGMENTED";
        hot-keys = true;
        scroll-panel-action = "CYCLE_WINDOWS";
      };
      "org/gnome/desktop/interface" = {
        font-antialiasing = "rgba";
        font-hinting = "slight";
        text-scaling-factor = 1.0;
        monospace-font-name = "JetBrainsMonoNL Nerd Font 12";
        font-name = "Cantarell 12";
        document-font-name = "Cantarell 12";
        enable-hot-corners = false;
        clock-format = "12h";
      };
      "org/gnome/shell/extensions/just-perfection" = {
        window-demands-attention-focus = true;
        startup-status = 0;
      };
      "org/gnome/desktop/wm/keybindings".panel-run-dialog = ["<Super>r"];
      "org/gnome/desktop/wm/preferences".titlebar-font = "Cantarell Bold 12";
      "org/gtk/settings/file-chooser".clock-format = "12h";
      "org/gnome/mutter".edge-tiling = true;
      "org/gnome/desktop/session".idle-delay = 600;
      "org/gnome/desktop/screensaver".lock-enabled = false;
      "org/gnome/Console".font-scale = 1.0;
    };
  };
}
