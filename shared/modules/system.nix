{ hostName, ... }:

{
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      # Without an explicit flake reference autoUpgrade falls back to channels,
      # which this config does not use.
      flake = "/etc/nixos#${hostName}";
    };

    stateVersion = "25.11";
  };
}
