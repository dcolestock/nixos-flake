{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Discord Krisp Patcher
    sersorrel-discord = {
      url = "github:sersorrel/sys";
      flake = false;
    };

    # Neovim
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-slime-cells = {
      url = "github:klafyvel/vim-slime-cells";
      flake = false;
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    specialArgs = {
      inherit inputs;
      inherit pkgs-unstable;
    };
  in {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = inputs.nixpkgs;}

        ./configuration.nix
        inputs.agenix.nixosModules.default

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dan = import ./home;
            extraSpecialArgs = specialArgs;
            backupFileExtension = ".bak";
          };
        }
      ];
    };
    homeConfigurations."dcolest" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = inputs.nixpkgs;}

        ./home/work.nix
      ];
      extraSpecialArgs = specialArgs;
    };
    formatter.${system} = pkgs.alejandra;
  };
}
