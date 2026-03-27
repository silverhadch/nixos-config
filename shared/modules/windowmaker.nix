{ config, lib, pkgs, ... }:

{
  # Use WindowMaker as the window manager
  services.xserver.windowManager.windowmaker.enable = true;

  # Install additional useful packages for a retro experience
  environment.systemPackages = with pkgs; [
    xterm                # classic terminal
    xclock               # analogue clock
    xeyes                # because why not
    bitmap               # bitmap editor
    alsa-utils           # for sound
  ];

  # Include bitmap fonts for that authentic 90s look
  fonts.packages = with pkgs; [
    font-bitstream-75dpi
    font-bitstream-100dpi
    font-misc-misc
  ];

  # (creates a default ~/GNUstep/Defaults/WindowMaker file on first login)
  system.activationScripts.windowmaker-setup = {
    deps = [];
    text = ''
      mkdir -p /etc/skel/GNUstep/Defaults
      if [ ! -f /etc/skel/GNUstep/Defaults/WindowMaker ]; then
        cat > /etc/skel/GNUstep/Defaults/WindowMaker <<EOF
      {
        MenuText = "X11";
        WorkspaceBack = "solid";
        WorkspaceBackSolid = "#003366";
        Dock = (
          { type = appicon; name = Terminal; command = "xterm"; },
          { type = appicon; name = XClock; command = "xclock"; }
        );
      }
      EOF
      fi
    '';
  };
}
