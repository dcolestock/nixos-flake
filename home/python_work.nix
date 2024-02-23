{pkgs, ...}: let
  my-python-packages = ps:
    with ps; [
      (
        buildPythonPackage rec {
          pname = "optumdb";
          version = "0.2.9";
          src = pkgs.fetchgit {
            url = "https://github.optum.com/dcoles1/optumdb";
            rev = "0.2.9";
            sha256 = "sha256-KO0RXQH4EwufLOFoPyL0gNSjApeeQOIlnd12Eusj/Q=";
          };
          doCheck = false;
          format = "pyproject";
          propagatedBuildInputs = with pkgs.python3Packages; [
            flit
            pandas
            JayDeBeApi
            more-itertools
          ];
        }
      )
    ];
in {
  home.packages = [(pkgs.python311.withPackages my-python-packages)];
}
