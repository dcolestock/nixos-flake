# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, inputs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./timers.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "pulsar-1.109.0"
    "electron-25.9.0"
  ];

  documentation.doc.enable = true;
  documentation.info.enable = true;
  documentation.dev.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.resolved.enable = true;

  # Video Card Drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    libGL
    amdvlk
    driversi686Linux.amdvlk # For 32 bit applications
  ];
  hardware.opengl.setLdLibraryPath = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    plasma-browser-integration
    konsole
    oxygen
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.printing.drivers = [ pkgs.brlaser ];

  services.gnome.gnome-remote-desktop.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "wireshark" ];
    packages = with pkgs; [
    ];
  };

  virtualisation.waydroid.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # General Command Line Tools
    eza
    bat
    fd
    fzf
    ripgrep
    xclip
    xsel
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
    libGL
    libsForQt5.qtwayland
    qt5.qtwayland
    qt6.qtwayland

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

    # Games
    endless-sky
    bsdgames

    # Gnome specific
    gnome3.gnome-tweaks
    gnome3.gnome-remote-desktop
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
    gnomeExtensions.just-perfection
    gnomeExtensions.allow-locked-remote-desktop

    # Nix tools
    alejandra # Nix code formatter
    manix # Nix doc searcher

    # System
    pavucontrol
    inotify-tools
    solaar
    inputs.agenix.packages."${system}".default

    # (lutris.override {
    #   extraLibraries = pkgs: [
    #   ];
    #   extraPkgs = pkgs: [
    #   ];
    # })
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # programs.ssh.forwardX11 = true;
  # programs.ssh.setXAuthLocation = true;

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
  };

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 33221 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.dan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvItECWiUFIPuGd7uQJcVp/sQJ0RnYh39y8sOQYNMUJ JuiceSSH"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN1n0+tmadg/GJ/igJf31nsluyHMcn2J6zaycloqipAeU+fa5b4V9rXUWntkGrJNP8CWloMx788ssGI1CYAmr/wbB95xJVrHckwx1O1/YE6D/bqLfdI02t9EqNVQS/3Dm1b63YxtupPR9yHFVCBIBoSz7C2lnCdPqYnXnB+75P1vVUvvBPvKcVSofETEbMByjMVLhPBa2Wry7zLb67JKZitH5MQidxqnQqU2w9g3/C28jW/hG3rRTXdJ+D7M2Iv/hZCuqQhZRhaAiU8t4Vk3iYNUn8de5oNCAI9KgWnNRQZ5xh+ypdph3yWteXLu7p4UZFtgUUvV0ExvEPAGtljlhF surface"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0LJdWfOIGs7qDDdUbVX46Gr6qWhan2FsR07PGOHNj04TrwENT+MMKkJmkG2ol51RoHnCbXAdW3+e5yHwgzoMDyKW4hqp34dDpvS+u+rAX4YwMrSWPkBRO1UvL88TNi9al47K8mtQI9/yhR96N76K9GbEC8T1oxVlKYaZyb/9nKwmthyA2x3wpI3DggseFQ7TwPGxHPDuI8oO7KvL2y1USFHUP4oETMbEHm+BKLjotV9nh6ibrSFjhosE09BVyA/0t5tx5K8qrrTWNmZJYdULMwtjeJtzOhFb4Yc2W3/aaxZmEwMFdPGGnTf5Yf7qDVMZ48VhyycsdzjFXN8CASCpf SamsungRDP"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAyBFhfJ59CyjEDU0INkew8VTCmoD3RNGTNGITtI8QqMbsFVX2RITaivyiX2uR0PgQgesV+EkjFs0u4IBrEjN8ZXmL4DdbCTG7Y7ESZcaYlytxTqKXqpaCz5m2f28MHBCrTTH8H+sfJOv2XAjszaUJ15KWiaPNpcM4tvCosFk1J2c+ccSoTDS45SMa+N7h8UyKw4uJk34hmEvhNlmu3+fUQfDM9bUcPlnvsD8/1Iak7UClB/HRpTinAs+T1sO5F+/pN3qs48zlocCRUiTp2Fr1zbbQw66FdPPL2J6l2OG+01wwNsGBRmi14hhdx+MgyolpEy/dx1KwBRPaVh8pAo4R Samsungconnectbot"
    # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6ROHJQAjPYwYjaapOBzZ6iIEKJqi7I+vKwiyBsehdzXZ0OYXPFWefmCVOLLby9C+/vcZ8fC6GJP+rRsVwQg2DBE3dPUUJfkFf+n0JYcdzJONEmijYZqs35yNHTrGImkSWagxc5uHzt8sCRzVrGr0qn9f16LLGYb0GOgbRRDw1ZEICblYfCaLhhAf+UWuYvE4HtSgipdheJGnfCePEkGfOMKICVBCgkbG+rCM/KIQSs45PPvcaM8X3uBxGWpKyaZSA9OhYRHpuH8Sh3tkBlk2z2yilpRFU4H0WkXD6iM43GXzadsRliGJT1C4bayAQW1afA328wJm0dbkEURTMDM+1o7jpPeypo/Xwba2SNfsIKBCNKQzPNRQ17mkNggg8upq22CEfNnPcO0gn4k0cNvy6rXPmO3E7Qkm5KG4uI4WDEq9YTYXkK7L1dL0tRDsi6dN1pRu+5KiyGZu3/iZRgq4OG59EAACqgBBh1kPERagpaCcSTBsdxSy1oNDrbEuUfTs= mark@jaycelyn"
    # note: ssh-copy-id will add user@clientmachine after the public key
    # but we can remove the "@clientmachine" part
  ];

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30, pwfeedback
  '';
  security.polkit.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
