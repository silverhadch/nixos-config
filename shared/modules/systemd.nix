{ pkgs, ... }:

{
  systemd = {

    #
    # Global systemd manager settings (NixOS 26+ compatible)
    #
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
  };
}
