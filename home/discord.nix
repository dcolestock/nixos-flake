{
  pkgs,
  inputs,
  ...
}: let
  krisp-patcher = pkgs.writers.writePython3Bin "krisp-patcher" {
    libraries = with pkgs.python312Packages; [capstone pyelftools];
    flakeIgnore = [
      "E501" # line too long (82 > 79 characters)
      "F403" # ‘from module import *’ used; unable to detect undefined names
      "F405" # name may be undefined, or defined from star imports: module
    ];
  } (builtins.readFile "${inputs.sersorrel-discord}/hm/discord/krisp-patcher.py");
in {
  home.packages = [
    pkgs.discord
    krisp-patcher
  ];
}