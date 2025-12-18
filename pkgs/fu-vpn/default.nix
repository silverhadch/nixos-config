{ pkgs }:

pkgs.writeShellApplication {
  name = "fu-vpn";

  runtimeInputs = [
    pkgs.openconnect
    pkgs.firefox
    pkgs.sudo
    pkgs.coreutils
  ];

  text = ''
    set -euo pipefail

    PIDFILE="/run/fu-vpn.pid"

    usage() {
      cat <<EOF
Usage: fu-vpn <command>

Commands:
  start       Start the FU VPN
  stop        Stop the FU VPN
  restart     Restart the FU VPN
  status      Show VPN status
  -h, --help  Show this help

EOF
    }

    require_root() {
      if [ "$EUID" -ne 0 ]; then
        echo "Must be run as root (use sudo)" >&2
        exit 1
      fi
    }

    is_running() {
      [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
    }

    start_vpn() {
      if is_running; then
        echo "fu-vpn already running (PID $(cat "$PIDFILE"))" >&2
        exit 1
      fi

      USER_NAME="$SUDO_USER"
      USER_UID="$(id -u "$USER_NAME")"

      export DISPLAY="''${DISPLAY:-:0}"
      export XDG_RUNTIME_DIR="/run/user/$USER_UID"
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

      BROWSER_WRAPPER="$(mktemp)"

      cat > "$BROWSER_WRAPPER" <<EOF
#!/bin/sh
exec ${pkgs.sudo}/bin/sudo -u "$USER_NAME" \
  DISPLAY="$DISPLAY" \
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
  ${pkgs.firefox}/bin/firefox "\$@"
EOF

      chmod +x "$BROWSER_WRAPPER"

      exec ${pkgs.openconnect}/bin/openconnect \
        --server=vpn.fu-berlin.de \
        --protocol=anyconnect \
        --useragent=AnyConnect \
        --external-browser="$BROWSER_WRAPPER" \
        --background \
        --pid-file="$PIDFILE"
    }

    stop_vpn() {
      if ! is_running; then
        echo "fu-vpn not running" >&2
        exit 1
      fi

      kill "$(cat "$PIDFILE")"
      rm -f "$PIDFILE"
      echo "fu-vpn stopped"
    }

    case "''${1:-}" in
      start)
        require_root
        start_vpn
        ;;

      stop)
        require_root
        stop_vpn
        ;;

      restart)
        require_root

        if ! is_running; then
          echo "fu-vpn not running, cannot restart" >&2
          exit 1
        fi

        stop_vpn
        start_vpn
        ;;

      status)
        require_root

        if is_running; then
          echo "fu-vpn running (PID $(cat "$PIDFILE"))"
        else
          echo "fu-vpn not running"
          exit 1
        fi
        ;;

      -h|--help|"")
        usage
        exit 0
        ;;

      *)
        echo "Unknown command: $1" >&2
        usage
        exit 1
        ;;
    esac
  '';
}
