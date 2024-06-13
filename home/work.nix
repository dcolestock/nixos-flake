{...}: {
  imports = [
    ./bash.nix
    ./sharedprograms.nix
    ./tmux.nix
    ./starship.nix
    ./neovim.nix
    ./python.nix
  ];
  # nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlay];
  programs.neovim.includeNodePackages = false;

  home.username = "dcolest";
  home.homeDirectory = "/home/dcolest";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
