{ pkgs, ... }:
let
  my-python-packages = ps: with ps; [
    ipython
    pip
    black
    isort
    mypy
    flake8
    types-pillow
    anyqt
    pyqt6
    scikit-learn
    opencv4

    pandas
    sympy
    numpy
    beautifulsoup4
    requests
    networkx
    more-itertools
    tqdm
    lxml
    tinycss2
    colormath

    pytesseract
    pillow
  ];
in {
home.packages = [(pkgs.python311.withPackages my-python-packages)];
}
