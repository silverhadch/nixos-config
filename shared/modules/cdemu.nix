{ config, pkgs, ... }:
{
boot.kernelModules = [ "vhba" ];

environment.systemPackages = with pkgs; [
  cdemu-client
  cdemu-daemon
];

services.dbus.packages = [ pkgs.cdemu-daemon ];

services.udev.extraRules = ''
  KERNEL=="vhba_ctl", MODE="0660", GROUP="cdrom"
'';

users.users.hadichokr.extraGroups = [ "cdrom" ];

systemd.user.services.cdemu-daemon = {
  description = "CDEmu Daemon";
  serviceConfig = {
    ExecStart = "${pkgs.cdemu-daemon}/bin/cdemu-daemon";
    Restart = "on-failure";
  };
};
}
