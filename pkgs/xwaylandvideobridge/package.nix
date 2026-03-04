{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  pkg-config,
  qtbase,
  qtdeclarative,
  kcoreaddons,
  kcrash,
  ki18n,
  kpipewire,
  kstatusnotifieritem,
  kwindowsystem,
  libxcb,
  xcbutil,
  wrapQtAppsHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xwaylandvideobridge";
  version = "0.4.0-kf6";

  src = builtins.fetchGit {
    url = "https://invent.kde.org/silverhadch/xwaylandvideobridge.git";
    ref = "master";
    rev = "7b7515d71f70421cdc17a0f7ddf1beb2e264669d";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtdeclarative
    kcoreaddons
    kcrash
    ki18n
    kpipewire
    kstatusnotifieritem
    kwindowsystem
    libxcb
    xcbutil
  ];

  meta = {
    description = "Utility to allow streaming Wayland windows to X applications";
    homepage = "https://invent.kde.org/silverhadch/xwaylandvideobridge";
    license = with lib.licenses; [
      bsd3
      cc0
      gpl2Plus
    ];
    maintainers = with lib.maintainers; [ stepbrobd ];
    platforms = lib.platforms.linux;
    mainProgram = "xwaylandvideobridge";
  };
})
