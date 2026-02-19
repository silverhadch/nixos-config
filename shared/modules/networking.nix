{ pkgs, hostName, ... }:

{
  networking = {
    hostName = hostName;

    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
      ];

      ensureProfiles.profiles.fuVpn = {
        connection = {
          id = "FU VPN";
          type = "vpn";
          autoconnect = false;
        };

        ipv4.method = "auto";
        ipv6.method = "disabled";

        vpn = {
          gateway = "vpn.fu-berlin.de";
          protocol = "anyconnect";
          service-type = "org.freedesktop.NetworkManager.openconnect";
          reported-os = "ios";
          reported-version = "5.1.6.103";
          useragent = "AnyConnect";
        };
      };
    };
  };
}
