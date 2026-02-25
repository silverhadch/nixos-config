{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../shared/configuration.nix

    ./modules/boot.nix
  ];
}

