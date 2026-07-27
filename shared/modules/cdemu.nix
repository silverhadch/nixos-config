{ pkgs, ... }:

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

  # NOTE: users that should be able to use CDEmu need the "cdrom" group,
  # see shared/users/<name>/user.nix.

  systemd.user.services.cdemu-daemon = {
    description = "CDEmu Daemon";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cdemu-daemon}/bin/cdemu-daemon";
      Restart = "on-failure";
    };
  };
}
