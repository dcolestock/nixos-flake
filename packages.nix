{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlay];

  nixpkgs.config.permittedInsecurePackages = [
    "pulsar-1.109.0"
    "electron-25.9.0"
  ];

  environment.systemPackages = with pkgs; [
    # General Command Line Tools
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
    du-dust
    duf
    # mcfly
    procs
    tldr
    nodePackages.pyright
    nodePackages.sql-formatter

    # General Command Line Applications
    taskwarrior
    rclone
    tmux
    poppler_utils # PDF Tools
    # pipe-viewer
    recapp

    # Toolchains
    openjdk17
    libgccjit
    poetry
    # libGL
    # libsForQt5.qtwayland
    # qt5.qtwayland
    # qt6.qtwayland

    # GUI Applications
    keepassxc
    libreoffice
    discord
    google-chrome
    chromium
    firefox
    obsidian
    heroic
    mpv
    pulsar
    wireshark
    kicad
    nyxt
    libsForQt5.krfb
    wl-clipboard
    wl-clipboard-x11

    # Games
    endless-sky
    bsdgames

    # Gnome specific
    # gnome3.gnome-tweaks
    # gnome3.gnome-remote-desktop
    # gnomeExtensions.dash-to-panel
    # gnomeExtensions.appindicator
    # gnomeExtensions.just-perfection
    # gnomeExtensions.allow-locked-remote-desktop

    # Nix tools
    alejandra # Nix code formatter
    manix # Nix doc searcher

    # System
    pavucontrol
    inotify-tools
    solaar
    inputs.agenix.packages."${system}".default
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    git.enable = true;
    wireshark.enable = true;
    adb.enable = true;
    kdeconnect.enable = true;
  };
}
