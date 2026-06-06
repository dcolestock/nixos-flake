{
  inputs,
  config,
  ...
}: let
  username_home = "dan";
  username_work = "dcoles1";
in {
  shared.inputs = inputs;
  shared.pkgsMaster = inputs.nixpkgs-master.legacyPackages.x86_64-linux;

  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      config.flake.modules.nixos.base
      config.flake.modules.nixos.hardware-base
      config.flake.modules.nixos.bluetooth
      config.flake.modules.nixos.packages
      config.flake.modules.nixos.tailscale
      config.flake.modules.nixos.plasma

      inputs.nix-index-database.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username_home} = {
            home.username = username_home;
            home.homeDirectory = "/home/${username_home}";
            imports = [
              config.flake.modules.homeManager.base
              config.flake.modules.homeManager.bash
              config.flake.modules.homeManager.byobu
              config.flake.modules.homeManager.plasma
              config.flake.modules.homeManager.distrobox
              config.flake.modules.homeManager.firefox
              config.flake.modules.homeManager.fish
              config.flake.modules.homeManager.neovim
              config.flake.modules.homeManager.minimax
              config.flake.modules.homeManager.python
              config.flake.modules.homeManager.packages
              config.flake.modules.homeManager.starship
              config.flake.modules.homeManager.tmux
            ];
          };
          backupFileExtension = ".bak";
        };
      }
      inputs.deferred-apps.nixosModules.default
      ({pkgs, ...}: {
        programs.deferredApps = {
          enable = true;
          packages = with pkgs; [
            gnucash
            kicad
            supertux
            supertuxkart
            extremetuxracer
          ];
        };
      })
    ];
  };

  flake.homeConfigurations."${username_work}" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
      {
        home.username = username_work;
        home.homeDirectory = "/home/${username_work}";
      }
      config.flake.modules.homeManager.work
    ];
  };
}
