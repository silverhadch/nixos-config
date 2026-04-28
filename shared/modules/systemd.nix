{ pkgs, ... }:

{
  systemd = {
   additionalUpstreamSystemUnits = [
    "soft-reboot.target"
    "systemd-soft-reboot.service"
  ];
    #
    # Global systemd manager settings (NixOS 26+ compatible)
    #
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
  };
}
