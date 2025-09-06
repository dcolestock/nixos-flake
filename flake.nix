{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";

    # Discord Krisp Patcher
    sersorrel-discord = {
      url = "github:sersorrel/sys";
      flake = false;
    };

    # Neovim
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-slime-cells = {
      url = "github:klafyvel/vim-slime-cells";
      flake = false;
    };
    nvim-fundo = {
      url = "github:kevinhwang91/nvim-fundo";
      flake = false;
    };
    showkeys = {
      url = "github:nvzone/showkeys";
      flake = false;
    };
    mini = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    username_home = "dan";
    username_work = "dcoles1";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    # pkgs-unstable = import inputs.nixpkgs-unstable {
    #   inherit system;
    #   config.allowUnfree = true;
    # };
    specialArgs = {
      inherit inputs;
      # inherit pkgs-unstable;
      username = username_home;
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
            users.${username_home} = import ./home;
            extraSpecialArgs = specialArgs;
            backupFileExtension = ".bak";
          };
        }
      ];
    };
    homeConfigurations."${username_work}" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
        {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
        ./home/work.nix
      ];
      extraSpecialArgs = specialArgs // {username = username_work;};
    };
    formatter.${system} = pkgs.alejandra;
  };
}
