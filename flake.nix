{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";

    # Discord Krisp Patcher
    sersorrel-discord = {
      url = "github:sersorrel/sys";
      flake = false;
    };

    deferred-apps.url = "github:WitteShadovv/deferred-apps/e6899eaffec705603e8efeb5d72ac1607b525b14";

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
    recover-vim = {
      url = "github:chrisbra/Recover.vim";
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

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    (inputs.import-tree ./modules);
}
