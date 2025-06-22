{config, ...}: {
  # Enable Bluetooth
  # $ bluetoothctl
  # # make sure bluetooth is enabled
  # [bluetooth]# scan on
  # [NEW] Device AA:BB:CC:DD:EE:FF Xbox Wireless Controller
  # [bluetooth]# pair AA:BB:CC:DD:EE:FF
  # [bluetooth]# trust AA:BB:CC:DD:EE:FF
  # [bluetooth]# connect AA:BB:CC:DD:EE:FF
  # [bluetooth]# scan off
  # [bluetooth]# exit
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      experimental = true; # show battery

      # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
      # for pairing bluetooth controller
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };
  services.blueman.enable = true;

  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [xpadneo];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
    # connect xbox controller
  };
}
