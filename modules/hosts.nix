{
  inputs,
  config,
  ...
}: let
  username_home = "dan";
  username_work = "dcoles1";
in {
  flake = {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        pkgs-master = inputs.nixpkgs-master.legacyPackages.x86_64-linux;
        username = username_home;
      };
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
              imports = [
                config.flake.modules.homeManager.base
                config.flake.modules.homeManager.bash
                config.flake.modules.homeManager.plasma
                config.flake.modules.homeManager.distrobox
                config.flake.modules.homeManager.firefox
                config.flake.modules.homeManager.neovim
                config.flake.modules.homeManager.python
                config.flake.modules.homeManager.packages
                config.flake.modules.homeManager.starship
                config.flake.modules.homeManager.tmux
              ];
            };
            extraSpecialArgs = {
              inherit inputs;
              pkgs-master = inputs.nixpkgs-master.legacyPackages.x86_64-linux;
              username = username_home;
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

    homeConfigurations."${username_work}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
        config.flake.modules.homeManager.work
      ];
      extraSpecialArgs = {
        inherit inputs;
        pkgs-master = inputs.nixpkgs-master.legacyPackages.x86_64-linux;
        username = username_work;
      };
    };
  };
}
