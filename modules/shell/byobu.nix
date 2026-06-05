{...}: {
  flake.modules.homeManager.byobu = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [byobu];

    home.file = {
      ".byobu/.tmux.conf".text = ''
        source-file ${config.xdg.configHome}/tmux/tmux.conf
      '';
    };
  };
}
