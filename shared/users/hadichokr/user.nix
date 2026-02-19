{ lib, pkgs, USERNAME, NAME, ... }:

{
  users.groups.libvirtd.members = [ USERNAME ];

  users.users.${USERNAME} = {
    description = NAME;
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

  # ------------------------------
  # Home Manager integration
  # ------------------------------
  home-manager = {
    extraSpecialArgs = { inherit USERNAME NAME; };

    users.${USERNAME} = import ./home-manager.nix;
  };
}
