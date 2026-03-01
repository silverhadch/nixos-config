{ pkgs, ... }:

{
  systemd = {

    #
    # Global systemd manager settings (NixOS 26+ compatible)
    #
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };

    #
    # User services
    #
    user = {

      #
      # Import graphical session environment into systemd --user
      # This fixes xdg-desktop-portal / xdg-open on Budgie/Wayland
      #
      services.import-graphical-environment = {
        description = "Import graphical session environment into systemd user";
        wantedBy    = [ "graphical-session.target" ];
        after       = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.systemd}/bin/systemctl --user import-environment \
              DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP \
              XDG_SESSION_TYPE XDG_DATA_DIRS PATH
          '';
        };
      };

      #
      # Polkit authentication agent
      #
      services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy    = [ "graphical-session.target" ];
        wants       = [ "graphical-session.target" ];
        after       = [ "graphical-session.target" ];
        serviceConfig = {
          Type           = "simple";
          ExecStart      = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart        = "on-failure";
          RestartSec     = 1;
          TimeoutStopSec = 10;
        };
      };

    };
  };
}
