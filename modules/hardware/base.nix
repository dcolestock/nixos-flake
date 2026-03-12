{...}: {
  flake.modules.nixos.hardware-base = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = ["dm-snapshot" "amdgpu"];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/8ebfdde0-e6c0-4ab7-a4d2-c891ae3fbf98";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/DA28-D264";
      fsType = "vfat";
    };

    swapDevices = [];
    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    systemd.tmpfiles.rules = [
      "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
        <!-- this should all be copied from your ~/.config/monitors.xml -->
        <monitors version="2">
          <configuration>
            <logicalmonitor>
              <x>1440</x>
              <y>0</y>
              <scale>1</scale>
              <monitor>
                <monitorspec>
                  <connector>HDMI-1</connector>
                  <vendor>VSC</vendor>
                  <product>VA2251 SERIES</product>
                  <serial>T1W141323022</serial>
                </monitorspec>
                <mode>
                  <width>1920</width>
                  <height>1080</height>
                  <rate>60.000</rate>
                </mode>
              </monitor>
            </logicalmonitor>
            <logicalmonitor>
              <x>0</x>
              <y>0</y>
              <scale>1</scale>
              <primary>yes</primary>
              <monitor>
                <monitorspec>
                  <connector>DP-3</connector>
                  <vendor>SAM</vendor>
                  <product>SyncMaster</product>
                  <serial>HVEL941812</serial>
                </monitorspec>
                <mode>
                  <width>1440</width>
                  <height>900</height>
                  <rate>59.887</rate>
                </mode></monitor>
            </logicalmonitor>
          </configuration>
        </monitors>
      ''}"
    ];
  };
}
