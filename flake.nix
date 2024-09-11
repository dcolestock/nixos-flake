{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-pin.url = "github:nixos/nixpkgs/e8057b67ebf307f01bdcc8fba94d94f75039d1f6";
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

    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-slime-cells = {
      url = "github:klafyvel/vim-slime-cells";
      flake = false;
    };

    sersorrel-discord = {
      url = "github:sersorrel/sys";
      flake = false;
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    # pkgs-pin = import inputs.nixpkgs-pin {
    #   inherit system;
    #   config.allowUnfree = true;
    # };
    specialArgs = {
      inherit inputs;
      # inherit pkgs-pin;
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
