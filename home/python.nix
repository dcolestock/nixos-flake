{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    ipython
    pip

    pillow
    types-pillow

    # Math and Data
    pandas
    sympy
    numpy
    networkx
    primecountpy

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
