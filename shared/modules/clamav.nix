{ config, lib, pkgs, ... }:

let
  fifoPath = "/run/clamav-alerts.fifo";

  virusEventScript = pkgs.writeShellScript "clamav-virus-event" ''
    ALERT="Signature detected by ClamAV: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
    if [ -p "${fifoPath}" ]; then
      echo "$ALERT" > "${fifoPath}"
    fi
  '';

  # Every normal user's home, so the per-user excludes apply to everyone.
  homes = map (u: u.home)
    (lib.filter (u: u.isNormalUser) (lib.attrValues config.users.users));

  # Relative to each home directory.
  homeExcludes = [
    ".local/share/containers"   # rootless podman = distrobox + toolbox storage
    ".local/share/flatpak"      # user flatpak installs
    ".var/app"                  # flatpak app data/caches
    ".local/share/PrismLauncher/instances/1.21.11/minecraft/backups"  # world backup zips
  ];

  systemExcludes = [
    "/var/lib/docker"
    "/var/lib/containers"       # rootful podman
    "/var/lib/flatpak"          # system flatpak installs
  ];

  onAccessExcludes =
    lib.concatMap (home: map (p: "${home}/${p}") homeExcludes) homes;

  # ExcludePath (used by the daily clamdscan run) takes regexes.
  scanExcludes =
    map (p: "^${lib.escapeRegex p}/") (systemExcludes ++ onAccessExcludes);
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

      # Default is 10; fewer threads = lower peak CPU during scans.
      MaxThreads = 4;

      OnAccessIncludePath = [ "/home" "/var/tmp" ];
      OnAccessExcludePath = onAccessExcludes;  # merges with minecraft-bedrock.nix
      OnAccessExcludeUname = "clamav";
      OnAccessPrevention = true;
      OnAccessExtraScanning = true;

      ExcludePath = scanExcludes;

      VirusEvent = "${virusEventScript}";
    };

    # freshclam normally loads the whole DB a second time to test every update,
    # which is a full-core spike several times a day.
    updater.settings.TestDatabases = false;

    scanner = {
      enable = true;
      interval = "*-*-* 04:00:00";
      # Default also includes /var/lib (docker, podman, flatpak, libvirt images…).
      scanDirectories = [ "/home" "/var/tmp" "/tmp" "/etc" ];
    };
  };

  # Podman (and distrobox/toolbox on top of it) unpacks image layers in
  # /var/tmp, which is on-access scanned. Use its own (excluded) storage instead.
  virtualisation.containers.containersConf.settings.engine.image_copy_tmp_dir = "storage";

  # Keep clamd from starving the desktop. CPUWeight only kicks in under
  # contention; CPUQuota caps it at 2 cores' worth.
  systemd.services.clamav-daemon.serviceConfig = {
    CPUWeight = 20;
    CPUQuota = "200%";
    IOWeight = 20;
    Nice = 10;
  };

  # Don't kick off a full /home scan on every nixos-rebuild; only the timer
  # starts it. (Otherwise switch-to-configuration waits until it finishes.)
  systemd.services.clamdscan.restartIfChanged = false;

  systemd.services.clamav-freshclam.serviceConfig = {
    CPUWeight = 20;
    Nice = 15;
    IOSchedulingClass = "idle";
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
