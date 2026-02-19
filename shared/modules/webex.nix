{
  systemd.user.paths.webex-watcher = {
    description = "Watch for Webex desktop file";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    pathConfig = {
      PathExistsGlob = [
        "%h/.local/share/applications/webex.desktop"
        "%h/.local/share/applications/Webex.desktop"
      ];
      Unit = "webex-remover.service";
    };
  };

  systemd.user.services.webex-remover = {
    description = "Remove Webex desktop file";
    serviceConfig.Type = "oneshot";

    script = ''
      echo "Removing Webex desktop file..."
      rm -f "$HOME/.local/share/applications/webex.desktop"
      rm -f "$HOME/.local/share/applications/Webex.desktop"
      rm -rf "$HOME/.local/share/WebexLauncher"
      rm -rf "$HOME/.local/share/webexLauncher"
    '';
  };
}
