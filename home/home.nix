{
  pkgs,
  username,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Mount Google Drive
  systemd.user.services = {
    rclone-startup = {
      Unit = {
        Description = "Run and sync rclone on login.";
      };
      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount --vfs-cache-mode writes gdrive: /home/dan/gdrive
        '';
        StandardOutput = "journal";
        Environment = ["PATH=/run/wrappers/bin"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMonoNL Nerd Font";
      size = 12;
    };
    settings = {
      background = "#282828";
    };
    extraConfig = ''
      enable_audio_bell no
      update_check_interval 0
      kitty_mod ctrl+shift
      tab_title_template "{index}: {title[title.rfind('/')+1:]}"
      mouse_map middle release ungrabbed paste_from_selection
      map kitty_mod+/ kitten keymap.py
      map kitty_mod+z toggle_layout stack
      map kitty_mod+w no_op
      map shift+cmd+d no_op
      map kitty_mod+q no_op
      map cmd+w       no_op
      cursor_trail 3
      cursor_trail_decay 0.1 0.4
    '';
  };
  xdg.configFile."kitty/keymap.py".source = ./scripts/kitty_keymap.py;
  home.packages = with pkgs; [
    atlauncher
    (prismlauncher.override {
      # Add binary required by some mod
      additionalPrograms = [ffmpeg];

      # Change Java runtimes available to Prism Launcher
      jdks = [
        graalvmPackages.graalvm-ce
        zulu8
        zulu17
        zulu
      ];
    })
  ];
}
