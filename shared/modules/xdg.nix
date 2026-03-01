{ pkgs, ... }:

let
  desktopFile = ''
    [Desktop Entry]
    Type=Application
    Name=Fix xdg-desktop-portal PATH
    Comment=Ensure xdg-desktop-portal has correct PATH
    Exec=sh -c 'systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service'
    X-GNOME-Autostart-enabled=true
    NoDisplay=false
  '';
in
{
  xdg.autostart.enable = true;

  environment.etc."xdg/autostart/fix-portal.desktop".text = desktopFile;
}
