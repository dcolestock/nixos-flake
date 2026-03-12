{...}: {
  flake.modules.homeManager.python = {pkgs, ...}: let
    my-python-packages = ps: with ps; [ipython pip qtconsole ipykernel jupyter tkinter intelhex uv matplotlib python-dotenv pandas sympy numpy sortedcontainers jsondiff openpyxl xlsxwriter demjson3 python-sat more-itertools tqdm icecream rich lxml pillow types-pillow];
  in {
    home.packages = [(pkgs.python312.withPackages my-python-packages)];
  };
}
