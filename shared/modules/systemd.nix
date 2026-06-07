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
      CPUQuota = "70%";
      MemoryMax = "70%";
    };
  };
}
