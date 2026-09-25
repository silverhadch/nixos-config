{ lib, pkgs, ... }:

let
  swapfile = "/var/lib/swapfile";
in
{
  # Plain swapfile on the (already LUKS-encrypted) root filesystem, so it stays
  # encrypted at rest *and* survives a reboot, which hibernation needs.
  # (The old randomEncryption swap got a fresh key every boot, so a hibernation
  # image written to it could never be read back.)
  #
  # mkForce also drops the stale "/dev/mapper/var-lib-swapfile" entry that
  # nixos-generate-config put into hardware-configuration.nix; without this,
  # boot would wait for that device and time out.
  swapDevices = lib.mkForce [{
    device = swapfile;
    size = 16 * 1024;
  }];

  # NixOS only runs mkswap when it creates the file. The existing file has the
  # right size but still holds old dm-crypt data, so format it once if it has
  # no swap signature. Does nothing on later boots.
  systemd.services.swapfile-format = {
    description = "Format ${swapfile} as swap if it isn't yet";
    after = [ "mkswap-var-lib-swapfile.service" ];
    before = [ "var-lib-swapfile.swap" ];
    requiredBy = [ "var-lib-swapfile.swap" ];
    unitConfig.DefaultDependencies = false;
    unitConfig.ConditionPathExists = swapfile;
    path = [ pkgs.util-linux ];
    script = ''
      if [ "$(blkid -p -s TYPE -o value ${swapfile} || true)" != swap ]; then
        chmod 600 ${swapfile}
        mkswap ${swapfile}
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
