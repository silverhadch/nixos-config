{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Home Manager (global integration)
  # ---------------------------------------------------------------------------
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;

    users.hadichokr = {
      imports = [ ./hadichokr-home.nix ];
    };
  };

  # ---------------------------------------------------------------------------
  # Users & groups
  # ---------------------------------------------------------------------------
  users = {
    groups.libvirtd.members = [ "hadichokr" ];

    users.hadichokr = {
      description = "Hadi Chokr";
      isNormalUser = true;

      extraGroups = [
        "docker"
        "input"
        "libvirtd"
        "networkmanager"
        "wheel"
      ];

      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];

      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];

      # all user-facing packages are managed by Home Manager
      packages = with pkgs; [
        home-manager
      ];
    };
  };
}
