{lib, ...}: {
  options.flake.modules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
    default = {};
    description = "Mergeable modules attribute for dendritic pattern";
  };

  options.shared = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
    description = "Shared values accessible via config instead of specialArgs";
  };
}
