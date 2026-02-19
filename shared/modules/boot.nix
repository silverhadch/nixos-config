{ config, pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    extraModulePackages = with config.boot.kernelPackages; [
      nullfs
      openafs
      openrazer
      v4l2loopback
      xone
      zfs_unstable
    ];

    kernelParams = [
      "boot.shell_on_fail"
      "quiet"
      "rd.systemd.show_status=auto"
      "splash"
      "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        edk2-uefi-shell.enable = true;
        memtest86.enable = true;
        netbootxyz.enable = true;
      };

      timeout = 0;
    };

    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };
  };
}
