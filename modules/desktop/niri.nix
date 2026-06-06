{...}: {
  flake.modules.nixos.niri = {pkgs, ...}: {
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [
      noctalia-shell
      alacritty
      fuzzel
      mako
      swaylock
      swayidle
      libnotify
      xwayland-satellite
    ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };

  flake.modules.homeManager.niri = {
    pkgs,
    config,
    ...
  }: {
    xdg.configFile."niri/config.kdl".text = ''
      spawn-at-startup "noctalia" "--autostart"

      input {
          keyboard {
              xkb {
                  layout "us"
              }
          }
      }

      binds {
          Mod+T { spawn "alacritty"; }
          Mod+D { spawn "fuzzel"; }
          Mod+L { spawn "swaylock"; }
          Mod+Shift+Q { close-window; }
          Mod+F { toggle-window-floating; }
          Mod+Shift+F { fullscreen-window; }
          Mod+H { focus-column-left; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }
          Mod+L { focus-column-right; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+J { move-window-down; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+L { move-column-right; }
          Mod+V { switch-preset-column-width; }
          Mod+Shift+Period { focus-workspace-next; }
          Mod+Shift+Comma { focus-workspace-prev; }
          Mod+Period { move-column-to-workspace-right; }
          Mod+Comma { move-column-to-workspace-left; }
      }
    '';
  };
}
