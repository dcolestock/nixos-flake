{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    ipython
    pip
    qtconsole
    ipykernel
    jupyter

    (
      buildPythonPackage rec {
        pname = "jupynium";
        version = "0.2.1";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-igAgSTQrRRfkKGZMp4FAqvAHo9AwsmK6S9u3b7X+qwI=";
        };
        doCheck = false;
        propagatedBuildInputs = with pkgs.python311Packages; [
          setuptools-scm
          selenium
          coloredlogs
          verboselogs
          pynvim
          psutil
          persist-queue
          packaging
          setuptools
          gitpython
        ];
      }
    )

    pillow
    types-pillow

    # Math and Data
    pandas
    sympy
    numpy
    networkx
    primecountpy
    sortedcontainers
    ply

    # Utilities
    more-itertools
    tqdm
    aocd
    icecream

    # Network
    beautifulsoup4
    requests
    lxml

    # LSP
    python-lsp-server
    python-lsp-ruff
    pyls-isort
    pylsp-rope
    pylsp-mypy
    black
    isort
    mypy
    flake8
    ruff-lsp

    # Machine Learning
    scikit-learn
    opencv4
    pytesseract
  ] ++ python-lsp-server.passthru.optional-dependencies.all;
in {
home.packages = [(pkgs.python311.withPackages my-python-packages)];
}
