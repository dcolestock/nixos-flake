{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    programs.neovim.includeNodePackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Whether to include nodePackages in build, in case npm is blocked";
    };
  };
  config = lib.mkIf config.programs.neovim.includeNodePackages {
    programs.neovim.extraPackages = with pkgs.nodePackages; [
      bash-language-server
      sql-formatter
      markdownlint-cli
      jsonlint
      # diagnostic-languageserver # Causes error when doing lsp format on .nix files
    ];
  };
}
