{ config, inputs, pkgs, lib, hostName, ... }:

{
  imports = [
    ./users

    ./modules/boot.nix
    ./modules/console-x11.nix
    ./modules/desktop.nix
    ./modules/environment.nix
    ./modules/flatpak.nix
    ./modules/fonts.nix
    ./modules/bluetooth.nix
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
    ./modules/system.nix
  ];
}
