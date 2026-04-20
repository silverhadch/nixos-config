{ config, lib, pkgs, ... }:
let
  dockerBtrfsFile = "/docker.btrfs";
  dockerBtrfsSize = "64G";
in
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  environment.systemPackages = [ pkgs.btrfs-progs ];

  # Make the socket wait for the mount — prevents socket-activation race
  systemd.sockets.docker = {
    after    = [ "var-lib-docker.mount" ];
    requires = [ "var-lib-docker.mount" ];
  };

  systemd.services.create-docker-btrfs = {
    description = "Create Btrfs backing file for Docker";
    wantedBy    = [ "multi-user.target" ];
    before      = [ "var-lib-docker.mount" ];
    requiredBy  = [ "var-lib-docker.mount" ];

    script = ''
      set -euo pipefail

      if [ ! -f ${dockerBtrfsFile} ]; then
        echo "Creating ${dockerBtrfsFile} (${dockerBtrfsSize})…"
        ${pkgs.coreutils}/bin/truncate -s ${dockerBtrfsSize} ${dockerBtrfsFile}
        echo "Formatting as Btrfs…"
        ${pkgs.btrfs-progs}/bin/mkfs.btrfs ${dockerBtrfsFile}
      else
        if ! ${pkgs.btrfs-progs}/bin/btrfs inspect-internal dump-super \
               ${dockerBtrfsFile} >/dev/null 2>&1; then
          echo "ERROR: ${dockerBtrfsFile} exists but is not a valid Btrfs image." >&2
          exit 1
        fi
        echo "${dockerBtrfsFile} already exists and is valid – skipping."
      fi

      mkdir -p /var/lib/docker
    '';

    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      UMask           = "0077";
    };
  };

  fileSystems."/var/lib/docker" = {
    device  = dockerBtrfsFile;
    fsType  = "btrfs";
    options = [ "loop" "noatime" "compress=zstd" ];
  };
}
