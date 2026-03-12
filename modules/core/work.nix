{self, ...}: {
  flake.modules.homeManager.work = {username, ...}: {
    imports = [
      self.modules.homeManager.bash
      self.modules.homeManager.sharedprograms
      self.modules.homeManager.tmux
      self.modules.homeManager.starship
      self.modules.homeManager.neovim
      self.modules.homeManager.python
    ];
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };
}
