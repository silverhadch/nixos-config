{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Home Manager Integration
  # ---------------------------------------------------------------------------
  home-manager = {
    # Backup existing files before overwriting with Home Manager managed files
    backupFileExtension = "backup";

    # Reuse system pkgs instead of creating a separate nixpkgs instance
    useGlobalPkgs = true;

    # Per-user Home Manager configuration imports
    users.hadichokr = {
      imports = [
        ./hadichokr-home-manager.nix
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Display Manager (Auto Login)
  # ---------------------------------------------------------------------------
  services.displayManager.autoLogin = {
    enable = true;
    user = "hadichokr";
  };

  # ---------------------------------------------------------------------------
  # Users / Groups
  # ---------------------------------------------------------------------------
  users = {
    # Ensure user is part of libvirtd group for VM and libvirt management
    groups.libvirtd.members = [ "hadichokr" ];

    users.hadichokr = {
      description = "Hadi Chokr";
      isNormalUser = true;

      # Force explicit group membership (override inherited defaults)
      extraGroups = lib.mkForce [
        "audio"
        "docker"
        "input"
        "libvirtd"
        "networkmanager"
        "video"
      ];

      # Subordinate GID range for rootless containers (Podman / user namespaces)
      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];

      # Subordinate UID range for rootless containers (Podman / user namespaces)
      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];

      # Per-user system packages (empty; Home Manager handles user packages)
      packages = with pkgs; [];
    };
  };
}
