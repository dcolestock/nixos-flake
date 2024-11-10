{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    via
    qmk
  ];
  services.udev.packages = [pkgs.via];
  hardware.keyboard.qmk.enable = true;
}
