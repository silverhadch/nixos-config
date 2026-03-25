{ config, pkgs, lib, ... }:

let
  systemdWithoutSpyware = pkgs.systemd.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or []) ++ [
      "-Duserdb=false"
      "-Dhomed=disabled"
    ];
  });
in {
  systemd.package = systemdWithoutSpyware;
  services.userdbd.enable = lib.mkForce false;
  systemd.services.systemd-userdbd.enable = lib.mkForce false;
  systemd.sockets.systemd-userdbd.enable = lib.mkForce false;

  # disable parental portal
  xdg.portal.config.common."org.freedesktop.impl.portal.ParentalControls" = "none";

  # block AccountsService birthdate API
  services.dbus.packages = [
    (pkgs.writeTextFile {
      name = "block-accountsservice-birthdate";
      destination = "/share/dbus-1/system.d/block-accountsservice-birthdate.conf";
      text = ''
        <!DOCTYPE busconfig PUBLIC
         "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
         "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy context="default">
            <deny send_member="GetBirthDate"/>
            <deny send_member="SetBirthDate"/>
          </policy>
        </busconfig>
      '';
    })
  ];
}
