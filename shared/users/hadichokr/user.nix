{ USERNAME, NAME, config, ... }:

{
  users.users.${USERNAME} = {
    description = NAME;
    isNormalUser = true;

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

  home-manager = {
    extraSpecialArgs = {
      inherit USERNAME NAME;
      osConfig = config;
    };
    users.${USERNAME} = import ./home-manager.nix;
  };
}
