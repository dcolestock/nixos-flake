{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    via
    qmk
    libusb1
    avrdude
    avrdudess
  ];
  services.udev.packages = [pkgs.via];
  hardware.keyboard.qmk.enable = true;
}
