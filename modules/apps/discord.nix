{inputs, ...}: {
  flake.modules.homeManager.discord = {pkgs, ...}: {
    home.packages = [
      pkgs.discord
      (pkgs.writers.writePython3Bin "krisp-patcher" {
        libraries = with pkgs.python312Packages; [capstone pyelftools];
        flakeIgnore = ["E501" "F403" "F405"];
      } (builtins.readFile "${inputs.sersorrel-discord}/hm/discord/krisp-patcher.py"))
    ];
  };
}
