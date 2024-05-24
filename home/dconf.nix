{
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

    "org/gnome/shell/extensions/just-perfection".window-demands-attention-focus = true;
    "org/gnome/shell/extensions/just-perfection".startup-status = 0;
    "org/gnome/desktop/wm/keybindings".panel-run-dialog = ["<Super>r"];
    "org/gnome/desktop/wm/preferences".titlebar-font = "Cantarell Bold 12";
    "org/gtk/settings/file-chooser".clock-format = "12h";
    "org/gnome/mutter".edge-tiling = true;
    "org/gnome/desktop/session".idle-delay = 600;
    "org/gnome/desktop/screensaver".lock-enabled = false;
    "org/gnome/Console".font-scale = 1.0;
  };
}
