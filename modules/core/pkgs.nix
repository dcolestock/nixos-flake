{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    _module.args.pkgs-master = import inputs.nixpkgs-master {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
