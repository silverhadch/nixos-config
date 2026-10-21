{ hostName, ... }:

{
  system = {
    autoUpgrade = {
      # Off: it rebuilt /etc/nixos including an uncommitted flake.lock from a
      # half-finished `update`, for hours in the background. Run `update`
      # by hand instead.
      enable = false;
      allowReboot = false;
      # Without an explicit flake reference autoUpgrade falls back to channels,
      # which this config does not use.
      flake = "/etc/nixos#${hostName}";
    };

    stateVersion = "25.11";
  };
}
