{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ydotool
  ];
  programs.ydotool.enable = true;
}
