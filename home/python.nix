{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    ipython
    pip
    qtconsole
    ipykernel
    jupyter

    # Images
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
    pygraphviz
    jsondiff

    # Utilities
    more-itertools
    tqdm
    aocd
    icecream
    rich

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
    sqlparse

    # Machine Learning
    scikit-learn
    opencv4
    pytesseract

    # Marimo
    (
      buildPythonPackage rec {
        pname = "marimo";
        version = "0.1.76";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-uOKd8s0MDSYMR1gf/MzsUQ5sbVl0FtH0I16kMxi94Yc=";
        };
        doCheck = false;
        format = "pyproject";
        propagatedBuildInputs = with pkgs.python3Packages; [
          setuptools-scm
          click
          importlib-resources
          jedi
          markdown
          pymdown-extensions
          pygments
          tomlkit
          tornado
          typing-extensions
          black
        ];
      }
    )
  ] ++ python-lsp-server.passthru.optional-dependencies.all;
in
{
  home.packages = [ (pkgs.python311.withPackages my-python-packages) ];
}
