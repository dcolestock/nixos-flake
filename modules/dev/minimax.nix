{...}: {
  flake.modules.homeManager.minimax = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.lib.file) mkOutOfStoreSymlink;
  in {
    xdg.configFile."minimax".source = mkOutOfStoreSymlink ./minimax;

    home.packages = with pkgs; [
      (writeShellApplication {
        name = "minimax";
        text = ''
          exec env NVIM_APPNAME=minimax nvim "$@"
        '';
      })
    ];
  };
}
