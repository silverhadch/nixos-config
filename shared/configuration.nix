{ ... }:

{
  imports = [
    ./users

    ./modules/audio.nix
    ./modules/avahi.nix
    ./modules/binfmt.nix
    ./modules/bluetooth.nix
    ./modules/boot.nix
    ./modules/cdemu.nix
    ./modules/console-x11.nix
    ./modules/desktop.nix
    ./modules/docker.nix
    ./modules/environment.nix
    ./modules/flatpak.nix
    ./modules/fonts.nix
    ./modules/kmscon.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/nix.nix
    ./modules/no-spyware-here.nix
    ./modules/printing.nix
    ./modules/programs.nix
    ./modules/security.nix
    ./modules/swap.nix
    ./modules/system.nix
    ./modules/systemd.nix
    ./modules/usershell.nix
    ./modules/virtualization.nix
  ];
}
