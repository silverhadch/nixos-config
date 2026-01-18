{ config, lib, pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;

    users.hadichokr = {
      imports = [
        ./hadichokr-home-manager.nix
      ];
    };
  };

  users = {
    groups.libvirtd.members = [ "hadichokr" ];

    users.hadichokr = {
      description = "Hadi Chokr";
      isNormalUser = true;

      extraGroups = lib.mkForce [
        "audio"
        "docker"
        "input"
        "libvirtd"
        "networkmanager"
        "video"
      ];

      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];

      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];

      packages = with pkgs; [];
    };
  };
}

