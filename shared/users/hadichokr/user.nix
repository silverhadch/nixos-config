{ USERNAME, NAME, ... }:

{
  users.users.${USERNAME} = {
    description = NAME;
    isNormalUser = true;

    # No mkForce here: other modules must be able to add groups of their own.
    extraGroups = [
      "adbusers"
      "audio"
      "cdrom"
      "dialout"
      "docker"
      "input"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "video"
      "wheel"
    ];

    subGidRanges = [
      { startGid = 100000; count = 65536; }
    ];

    subUidRanges = [
      { startUid = 100000; count = 65536; }
    ];
  };

  # ------------------------------
  # Home Manager integration
  # ------------------------------
  home-manager = {
    extraSpecialArgs = { inherit USERNAME NAME; };

    users.${USERNAME} = import ./home-manager.nix;
  };
}
