{
  pkgs,
  inputs,
  # pkgs-unstable,
  ...
}: {
  # nixpkgs.overlays = [
  # (self: super: {
  #   python311 = super.python311.override {
  #     x11Support = true;
  #   };
  # })
  # (self: super: {
  #   python312 = super.python312.override {
  #     x11Support = true;
  #   };
  # })
  # inputs.neovim-nightly-overlay.overlay
  # ];

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
    nodePackages.sql-formatter
    pre-commit
    devenv

    # General Command Line Applications
    taskwarrior3
    rclone
    tmux
    poppler_utils # PDF Tools
    # pipe-viewer
    recapp
    gemini-cli

    # Toolchains
    openjdk17
    libgccjit
    poetry
    # libGL
    # libsForQt5.qtwayland
    # qt5.qtwayland
    # qt6.qtwayland
    cabextract # tool for fixing sins of solar empire 2

    # GUI Applications
    keepassxc
    libreoffice
    google-chrome
    chromium
    firefox
    # librewolf
    obsidian
    heroic
    mpv
    # pulsar
    # wireshark
    # kicad
    # nyxt
    kdePackages.krfb
    wl-clipboard
    # wl-clipboard-x11
    xclip
    xdotool
    (pkgs.symlinkJoin {
      name = "neovide-wrapped";
      paths = [pkgs.neovide];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/neovide \
          --prefix LD_LIBRARY_PATH : ${pkgs.xorg.libX11}/lib
      '';
    })
    newsflash
    virt-manager
    virt-viewer
    qemu
    # gnucash
    gparted

    # Games
    # endless-sky
    # bsdgames

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
    nh

    # System
    pavucontrol
    inotify-tools
    solaar
    inputs.agenix.packages."${system}".default
  ];

  programs = {
    noisetorch.enable = true;
    steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
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
    fish.enable = true;
    # zsh.enable = true;
  };
}
