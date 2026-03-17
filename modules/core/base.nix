{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        bash-prompt-prefix = "(nix:$name)\\040";
        substituters = ["https://cache.thalheim.io" "https://nix-community.cachix.org" "https://neovim-nightly.cachix.org" "https://cache.nixos.org/"];
        trusted-public-keys = ["cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "neovim-nightly.cachix.org-1:feIoInHRevVEplgdZvQDjhp11kYASYCE2NGY9hNrwxY=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
        trusted-users = ["root" "dan"];
      };
      optimise.automatic = true;
      gc.automatic = true;
      gc.dates = "weekly";
    };
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [stdenv.cc.cc zlib openssl libffi libdvdread libdvdnav libdvdcss python312];
    environment.pathsToLink = ["/share/bash-completion"];
    documentation = {
      doc.enable = true;
      info.enable = true;
      dev.enable = true;
    };
    boot.loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 8;
    };
    system.nixos.label = "";
    boot.loader.efi.canTouchEfiVariables = true;
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;
    time.timeZone = "America/Chicago";
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
    virtualisation = {
      docker.enable = true;
      podman.enable = true;
      waydroid.enable = true;
      libvirtd = {
        enable = true;
        qemu.runAsRoot = true;
      };
    };
    services.xserver.enable = true;
    services.resolved.enable = true;
    services.xserver.videoDrivers = ["amdgpu"];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [libGL];
    };
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";
    services.displayManager.sddm.wayland.enable = false;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [plasma-browser-integration konsole];
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    services.printing = {
      enable = true;
      drivers = [pkgs.brlaser];
      listenAddresses = ["*:631"];
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
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
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    users.users.dan = {
      isNormalUser = true;
      description = "dan";
      extraGroups = ["adbusers" "cdrom" "dialout" "docker" "kvm" "libvirtd" "networkmanager" "qemu-libvirtd" "uucp" "wheel" "wireshark"];
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvItECWiUFIPuGd7uQJcVp/sQJ0RnYh39y8sOQYNMUJ JuiceSSH" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN1n0+tmadg/GJ/igJf31nsluyHMcn2J6zaycloqipAeU+fa5b4V9rXUWntkGrJNP8CWloMx788ssGI1CYAmr/wbB95xJVrHckwx1O1/YE6D/bqLfdI02t9EqNVQS/3Dm1b63YxtupPR9yHFVCBIBoSz7C2lnCdPqYnXnB+75P1vVUvvBPvKcVSofETEbMByjMVLhPBa2Wry7zLb67JKZitH5MQidxqnQqU2w9g3/C28jW/hG3rRTXdJ+D7M2Iv/hZCuqQhZRhaAiU8t4Vk3iYNUn8de5oNCAI9KgWnNRQZ5xh+ypdph3yWteXLu7p4UZFtgUUvV0ExvEPAGtljlhF surfaceputty" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCtZLxPRpKCYsiAT/RxZpyOZKWMAGNti2p9mi8QoiCzB2k7huONflsZQgi+Np9754d65NIQN6wGZUwmrRD1dRFxykACFYnWH+q8GvnltGFwKVqAn0JLvHI3+UJGa04Xm/+v5fxjZ9wbEBZ7+mjZ22VJ9Z6xPEG/VQnAl3fMaVUsGjNLmM3TNAV4j/FoJVGi3sqX0GCt1CuIAs4BtPalfPOSnsHdLag4vR316pUM+HnFIwZ4P2sjCC8iY+y2+xIZU38lXM0vTT+fjq7Iqg7MsPR54WTPL3NTG0Re8C7s0S45hef3JVk9jhlWjqJLkjYmNy+0x4dbxar24EYXy0IOJo6Pj/7z9qhdaEgYIHcy1rA4Xe1d34cDrQWK/IRswLu3B/a7jOgkYybruhM0/uZoF2ijAwMk1FGtJf8pZwwCXL8C8b1yWS63TIU/HMcBp8hFPRefB3CacjM0AQub1TfPRF3IQwqha1GlOzHTobHWeLNH4cJliw7ruXTry5XOMYvGJ2yP/4D1WTY7QZ0QDQ6IP+F4kXW9E/vTDM/neqgTrzGgTcfgwjIn+D7s0rg4rDkQZMbhMLBaANiCJdJVIMMFhWNV2NMqMqmbNzdVE/pIosLpwAj+ZOCWqYYFLWjHGhCMxJHS6h4sgzzf4IhYlqhaWHld7d6jGhhGXYwwYDlOcoaVrQ== SurfaceWindowsTerminal" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0LJdWfOIGs7qDDdUbVX46Gr6qWhan2FsR07PGOHNj04TrwENT+MMKkJmkG2ol51RoHnCbXAdW3+e5yHwgzoMDyKW4hqp34dDpvS+u+rAX4YwMrSWPkBRO1UvL88TNi9al47K8mtQI9/yhR96N76K9GbEC8T1oxVlKYaZyb/9nKwmthyA2x3wpI3DggseFQ7TwPGxHPDuI8oO7KvL2y1USFHUP4oETMbEHm+BKLjotV9nh6ibrSFjhosE09BVyA/0t5tx5K8qrrTWNmZJYdULMwtjeJtzOhFb4Yc2W3/aaxZmEwMFdPGGnTf5Yf7qDVMZ48VhyycsdzjFXN8CASCpf SamsungRDP" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAyBFhfJ59CyjEDU0INkew8VTCmoD3RNGTNGITtI8QqMbsFVX2RITaivyiX2uR0PgQgesV+EkjFs0u4IBrEjN8ZXmL4DdbCTG7Y7ESZcaYlytxTqKXqpaCz5m2f28MHBCrTTH8H+sfJOv2XAjszaUJ15KWiaPNpcM4tvCosFk1J2c+ccSoTDS45SMa+N7h8UyKw4uJk34hmEvhNlmu3+fUQfDM9bUcPlnvsD8/1Iak7UClB/HRpTinAs+T1sO5F+/pN3qs48zlocCRUiTp2Fr1zbbQw66FdPPL2J6l2OG+01wwNsGBRmi14hhdx+MgyolpEy/dx1KwBRPaVh8pAo4R Samsungconnectbot"];
    };
    nixpkgs.config.allowUnfree = true;
    fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono];
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
    services.openssh = {
      enable = true;
      ports = [33221];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    security.sudo.extraConfig = "Defaults timestamp_timeout=30, pwfeedback";
    security.polkit.enable = true;
    networking.firewall.allowedTCPPorts = [3389];
    networking.firewall.allowedUDPPorts = [3389];
    system.stateVersion = "23.05";
  };

  flake.modules.homeManager.base = {
    pkgs,
    username,
    ...
  }: {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    systemd.user.services.rclone-startup = {
      Unit.Description = "Run and sync rclone on login.";
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode writes gdrive: /home/dan/gdrive";
        StandardOutput = "journal";
        Environment = ["PATH=/run/wrappers/bin"];
      };
      Install.WantedBy = ["default.target"];
    };
    services.activitywatch.enable = true;
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMonoNL Nerd Font";
        size = 12;
      };
      settings.background = "#282828";
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
    xdg.configFile."kitty/keymap.py".source = ../assets/scripts/kitty_keymap.py;
    home.packages = with pkgs; [
      (prismlauncher.override {
        additionalPrograms = [ffmpeg];
        jdks = [graalvmPackages.graalvm-ce zulu8 zulu17 zulu];
      })
    ];
  };
}
