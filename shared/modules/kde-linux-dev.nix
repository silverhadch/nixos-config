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

  systemd.sockets.docker = {
    after = [ "var-lib-docker.mount" ];
    wants = [ "var-lib-docker.mount" ];
  };

  systemd.services.create-docker-btrfs = {
    description = "Create or recover Btrfs backing file for Docker";
    wantedBy    = [ "multi-user.target" ];
    before      = [ "var-lib-docker.mount" ];
    wantedBy    = [ "var-lib-docker.mount" ];
    script = ''
      set -uo pipefail

      create_image() {
        echo "Creating ${dockerBtrfsFile} (${dockerBtrfsSize})…"
        ${pkgs.coreutils}/bin/truncate -s ${dockerBtrfsSize} ${dockerBtrfsFile} || return 1
        echo "Formatting as Btrfs…"
        ${pkgs.btrfs-progs}/bin/mkfs.btrfs ${dockerBtrfsFile} || {
          rm -f ${dockerBtrfsFile}
          return 1
        }
      }

      if [ -f ${dockerBtrfsFile} ]; then
        if ${pkgs.btrfs-progs}/bin/btrfs inspect-internal dump-super \
             ${dockerBtrfsFile} >/dev/null 2>&1; then
          echo "${dockerBtrfsFile} is valid – skipping creation."
        else
          # Corrupt image: quarantine and recreate rather than hard-failing
          bad="${dockerBtrfsFile}.corrupt-$(date +%s)"
          echo "WARNING: ${dockerBtrfsFile} is corrupt, moving to $bad" >&2
          mv "${dockerBtrfsFile}" "$bad" || { echo "Could not quarantine corrupt image" >&2; exit 1; }
          create_image || exit 1
        fi
      else
        create_image || exit 1
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
    options = [ "loop" "noatime" "compress=zstd" "nofail" "x-systemd.device-timeout=15" ];
  };
}
