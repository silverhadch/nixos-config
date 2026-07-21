{ pkgs, hostName, ... }:

{

  # ModemManager is pulled in by NetworkManager, but being explicit doesn't hurt:
  systemd.services.ModemManager.enable = true;

  # FCC unlock for Lenovo-branded modems (needed if a Quectel/Fibocom ever appears)
  networking.networkmanager.fccUnlockScripts = [
    {
      id = "2c7c:6008";  # Quectel EM061K-GL, the usual Gen 13 module
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/2c7c";
    }
  ];

  # Handy tools
  environment.systemPackages = with pkgs; [
    usbutils      # lsusb
    pciutils      # lspci
    modemmanager  # mmcli
  ];

  services.udev.packages = [ pkgs.mobile-broadband-provider-info ];

  networking = {
    hostName = hostName;

    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
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
