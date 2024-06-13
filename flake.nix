{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-pin.url = "github:nixos/nixpkgs/e8057b67ebf307f01bdcc8fba94d94f75039d1f6";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-pin,
    home-manager,
    agenix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-pin = import nixpkgs-pin {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit pkgs-pin;
      };
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = nixpkgs;}

        ./configuration.nix
        agenix.nixosModules.default

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dan = import ./home;
            extraSpecialArgs = {
              inherit pkgs-pin;
            };
          };
        }
      ];
    };
    homeConfigurations."dcolest" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs-pin {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = nixpkgs;}

        ./home/work.nix
      ];
      extraSpecialArgs = {
        inherit inputs;
        inherit pkgs-pin;
      };
    };
    formatter.${system} = pkgs.alejandra;
  };
}
