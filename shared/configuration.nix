{ config, inputs, pkgs, lib, hostName, ... }:

{
  imports = [
    ./users

    ./modules/binfmt.nix
    ./modules/boot.nix
    ./modules/console-x11.nix
    ./modules/desktop.nix
    ./modules/environment.nix
    ./modules/flatpak.nix
    ./modules/fonts.nix
    ./modules/bluetooth.nix
    ./modules/kmscon.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/nix.nix
    ./modules/avahi.nix
    ./modules/printing.nix
    ./modules/audio.nix
    ./modules/programs.nix
    ./modules/swap.nix
    ./modules/usershell.nix
    ./modules/security.nix
    ./modules/virtualization.nix
    ./modules/webex.nix
    ./modules/windowmaker.nix

    ./modules/system.nix
    ./modules/systemd.nix

    # KDE Linux Dev
    ./modules/kde-linux-dev.nix

    # Patches
    ./modules/no-spyware-here.nix
  ];
}
