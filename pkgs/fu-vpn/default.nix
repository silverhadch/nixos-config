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

    case "''${1:-start}" in
      start)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
          echo "fu-vpn already running (PID $(cat "$PIDFILE"))"
          exit 0
        fi

        if [ "$EUID" -ne 0 ]; then
          echo "Must be run as root (use sudo)" >&2
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
        ;;

      stop)
        if [ ! -f "$PIDFILE" ]; then
          echo "fu-vpn not running"
          exit 0
        fi

        kill "$(cat "$PIDFILE")"
        rm -f "$PIDFILE"
        echo "fu-vpn stopped"
        ;;

      status)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
          echo "fu-vpn running (PID $(cat "$PIDFILE"))"
        else
          echo "fu-vpn not running"
          exit 1
        fi
        ;;

      *)
        echo "Usage: fu-vpn [start|stop|status]"
        exit 1
        ;;
    esac
  '';
}
