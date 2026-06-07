{ pkgs, ... }:

{
  systemd = {
    #
    # Global systemd manager settings (NixOS 26+ compatible)
    #
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
    services.nix-daemon.serviceConfig = {
      CPUWeight = 70;      # relative weight, not a percentage of cores
      MemoryMax = "70%";   # percentage of total RAM
      MemorySwapMax = "0"; # don't let it swap either
    };
  };
}
