{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.distrobox];

  xdg.configFile = {
    "distrobox/distrobox.conf".text = ''
      container_always_pull="1"
      container_generate_entry=1
      container_manager="podman"
    '';

    "distrobox/distrobox.ini" = {
      text = pkgs.lib.generators.toINI {} {
        ubuntu = {
          image = "quay.io/toolbx/ubuntu-toolbox:latest";
          additional_packages = "git neovim nodejs eza fd-find fzf";
          pull = true;
          root = false;
          replace = true;
        };
      };
      onChange = ''
        # distrobox assemble create --file "$out"
        export PATH=${pkgs.podman}/bin:$PATH
        ${pkgs.lib.getExe' pkgs.distrobox "distrobox"} assemble create --file ${config.xdg.configHome}/distrobox/distrobox.ini
      '';
    };
  };
}
