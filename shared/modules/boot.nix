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
      limine = {
        enable = true;
        maxGenerations = 5;
        enableEditor = false;
        extraConfig = ''
          quiet: yes
        '';
        secureBoot = {
          enable = true;
          autoGenerateKeys = true;
          autoEnrollKeys = {
            enable = true;
            extraArgs = [ "--microsoft" ];
          };
        };
      };
      timeout = 3;
    };
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [ nixos-bgrt-plymouth ];
    };
  };

  environment.systemPackages = with pkgs; [ sbctl ];
}
