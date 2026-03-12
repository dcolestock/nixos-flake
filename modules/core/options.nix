{lib, ...}: {
  options.flake.modules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
    default = {};
    description = "Mergeable modules attribute for dendritic pattern";
  };
}
