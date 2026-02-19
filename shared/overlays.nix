# overlays.nix
[
  ################################################################################
  # Bottles overlay
  ################################################################################
  (self: super: {
    bottles = super.bottles.override { removeWarningPopup = true; };
  })

  ################################################################################
  # Webex overlay
  ################################################################################
  (self: super: {
    webex = super.webex.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/opt/Webex/bin/CiscoCollabHost \
          --set WAYLAND_DISPLAY "" \
          --set XDG_SESSION_TYPE x11 \
          --set QT_QPA_PLATFORM xcb \
          --set GDK_BACKEND x11 \
          --set NIXOS_OZONE_WL 0
      '';
    });
  })
]
