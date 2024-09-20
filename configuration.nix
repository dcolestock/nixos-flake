{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./timers.nix
    # ./vimgolf.nix
    ./packages.nix
    # ./tailscale.nix
  ];
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      bash-prompt-prefix = "(nix:$name)\\040";
      substituters = [
        "https://cache.thalheim.io"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    optimise.automatic = true;
    gc.automatic = true;
    gc.dates = "weekly";

    # channel.enable = false; # Remove channels entirely at some point, but this errors currently
  };

  documentation.doc.enable = true;
  documentation.info.enable = true;
  documentation.dev.enable = true;

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    editor = false;
    configurationLimit = 18;
    # consoleMode = "max";
  };
  system.nixos.label = "";
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

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.resolved.enable = true;

  # Video Card Drivers
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libGL
      amdvlk
      driversi686Linux.amdvlk # For 32 bit applications
    ];
  };

  # Enable the GNOME Desktop Environment.
  # services.displayManager.displayManager.gdm.enable = true;
  # services.displayManager.desktopManager.gnome.enable = true;
  # services.gnome.gnome-remote-desktop.enable = true;

  # Enable the Plasma 6 Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.printing.drivers = [pkgs.brlaser];
  services.ollama.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    enableAllFirmware = true;
  };

  # Enable sound with pipewire.
  # sound.enable = true;
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

  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = ["networkmanager" "wheel" "adbusers" "wireshark" "docker" "libvirtd" "kvm" "qemu-libvirtd"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvItECWiUFIPuGd7uQJcVp/sQJ0RnYh39y8sOQYNMUJ JuiceSSH"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN1n0+tmadg/GJ/igJf31nsluyHMcn2J6zaycloqipAeU+fa5b4V9rXUWntkGrJNP8CWloMx788ssGI1CYAmr/wbB95xJVrHckwx1O1/YE6D/bqLfdI02t9EqNVQS/3Dm1b63YxtupPR9yHFVCBIBoSz7C2lnCdPqYnXnB+75P1vVUvvBPvKcVSofETEbMByjMVLhPBa2Wry7zLb67JKZitH5MQidxqnQqU2w9g3/C28jW/hG3rRTXdJ+D7M2Iv/hZCuqQhZRhaAiU8t4Vk3iYNUn8de5oNCAI9KgWnNRQZ5xh+ypdph3yWteXLu7p4UZFtgUUvV0ExvEPAGtljlhF surface"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0LJdWfOIGs7qDDdUbVX46Gr6qWhan2FsR07PGOHNj04TrwENT+MMKkJmkG2ol51RoHnCbXAdW3+e5yHwgzoMDyKW4hqp34dDpvS+u+rAX4YwMrSWPkBRO1UvL88TNi9al47K8mtQI9/yhR96N76K9GbEC8T1oxVlKYaZyb/9nKwmthyA2x3wpI3DggseFQ7TwPGxHPDuI8oO7KvL2y1USFHUP4oETMbEHm+BKLjotV9nh6ibrSFjhosE09BVyA/0t5tx5K8qrrTWNmZJYdULMwtjeJtzOhFb4Yc2W3/aaxZmEwMFdPGGnTf5Yf7qDVMZ48VhyycsdzjFXN8CASCpf SamsungRDP"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAyBFhfJ59CyjEDU0INkew8VTCmoD3RNGTNGITtI8QqMbsFVX2RITaivyiX2uR0PgQgesV+EkjFs0u4IBrEjN8ZXmL4DdbCTG7Y7ESZcaYlytxTqKXqpaCz5m2f28MHBCrTTH8H+sfJOv2XAjszaUJ15KWiaPNpcM4tvCosFk1J2c+ccSoTDS45SMa+N7h8UyKw4uJk34hmEvhNlmu3+fUQfDM9bUcPlnvsD8/1Iak7UClB/HRpTinAs+T1sO5F+/pN3qs48zlocCRUiTp2Fr1zbbQw66FdPPL2J6l2OG+01wwNsGBRmi14hhdx+MgyolpEy/dx1KwBRPaVh8pAo4R Samsungconnectbot"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
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
    ports = [33221];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30, pwfeedback
  '';
  security.polkit.enable = true;

  # Open RDP ports in the firewall.
  networking.firewall.allowedTCPPorts = [3389];
  networking.firewall.allowedUDPPorts = [3389];
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
