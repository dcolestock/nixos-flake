{pkgs, ...}: let
  my-python-packages = ps:
    with ps; [
      ipython
      pip
      qtconsole
      ipykernel
      jupyter
      tkinter
      intelhex

      # Math and Data
      pandas
      sympy
      numpy
      sortedcontainers
      jsondiff
      # datascroller
      openpyxl
      xlsxwriter
      demjson3
      python-sat

      # Utilities
      more-itertools
      tqdm
      icecream
      rich

      # Network
      # beautifulsoup4
      # requests
      # lxml

      # LSP
      # python-lsp-server
      # rope
      # toml
      # whatthepatch

      # ruff-lsp
      # sqlparse

      # optumdb
      # pyodbc
      # marimo

      # Images
      pillow
      types-pillow

      # Math and Data
      # networkx
      # primecountpy
      # ply
      # pygraphviz
      # jsondiff

      # Utilities
      # aocd

      # Machine Learning
      # scikit-learn
      # opencv4
      # pytesseract
    ];
in {
  home.packages = [(pkgs.python311.withPackages my-python-packages)];
}
