{pkgs, ...}: let
  my-python-packages = ps:
    with ps;
      [
        ipython
        pip
        qtconsole
        ipykernel
        jupyter

        # Math and Data
        pandas
        sympy
        numpy
        sortedcontainers
        jsondiff
        datascroller

        # Utilities
        more-itertools
        tqdm
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
      ]
      ++ python-lsp-server.passthru.optional-dependencies.all;
in {
  home.packages = [(pkgs.python311.withPackages my-python-packages)];
}
