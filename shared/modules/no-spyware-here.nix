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
}
