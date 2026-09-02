{ config, pkgs, ... }:

let
  fifoPath = "/run/clamav-alerts.fifo";

  virusEventScript = pkgs.writeShellScript "clamav-virus-event" ''
    ALERT="Signature detected by ClamAV: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
    if [ -p "${fifoPath}" ]; then
      echo "$ALERT" > "${fifoPath}"
    fi
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/clamav/tmp 0750 clamav clamav -"
    "p ${fifoPath} 0666 root root -"
  ];

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    clamonacc.enable = true;

    daemon.settings = {
      TemporaryDirectory = "/var/lib/clamav/tmp";
      OnAccessIncludePath = [ "/home" "/var/tmp" ];
      OnAccessExcludeUname = "clamav";
      OnAccessPrevention = true;
      OnAccessExtraScanning = true;
      VirusEvent = "${virusEventScript}";
    };

    scanner = {
      enable = true;
      interval = "*-*-* 04:00:00";
    };
  };

  systemd.user.services.clamav-notifier = {
    description = "ClamAV Desktop Notification Listener";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    script = ''
      while true; do
        if read -r line < "${fifoPath}"; then
          ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-warning "Virus Found!" "$line"
        fi
      done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "2s";
    };
  };

  boot.kernelParams = [ "fanotify" ];
}
