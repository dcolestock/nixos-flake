{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";

    home-manager.url = "github:nix-community/home-manager";
    # home-manager.url = "git+file:/home/dan/Projects/dancolestock/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    agenix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
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
            extraSpecialArgs = {};
          };
        }
      ];
    };
    homeConfigurations."dcolest" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = nixpkgs;}

        ./home/work.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };
    formatter.${system} = pkgs.alejandra;
  };
}
