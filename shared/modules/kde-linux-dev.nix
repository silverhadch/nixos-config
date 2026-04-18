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

  fileSystems."/var/lib/docker" = {
    device = dockerBtrfsFile;
    fsType = "btrfs";
    options = [ "loop" "noatime" ];
    neededForBoot = false;
  };

  systemd.services.create-docker-btrfs = {
    description = "Create Btrfs backing file for Docker";
    before = [ "var-lib-docker.mount" "docker.service" ];
    requiredBy = [ "var-lib-docker.mount" "docker.service" ];
    script = ''
      set -e
      if [ ! -f ${dockerBtrfsFile} ]; then
        echo "Creating ${dockerBtrfsFile} (${dockerBtrfsSize}) ..."
        ${pkgs.util-linux}/bin/fallocate -l ${dockerBtrfsSize} ${dockerBtrfsFile}
        echo "Formatting as Btrfs ..."
        ${pkgs.btrfs-progs}/bin/mkfs.btrfs ${dockerBtrfsFile}
      else
        # Check if it's already a btrfs filesystem
        if ! ${pkgs.btrfs-progs}/bin/btrfs inspect-internal dump-super ${dockerBtrfsFile} >/dev/null 2>&1; then
          echo "ERROR: ${dockerBtrfsFile} exists but is not a btrfs filesystem. Please remove or fix it."
          exit 1
        fi
        echo "${dockerBtrfsFile} already exists and is a btrfs filesystem – skipping creation."
      fi
      # Ensure the mount point directory exists (the mount unit will use it)
      mkdir -p /var/lib/docker
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services."var-lib-docker.mount" = {
    after = [ "create-docker-btrfs.service" ];
    requires = [ "create-docker-btrfs.service" ];
  };
}
