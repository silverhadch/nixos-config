{
  lib,
  stdenv,
  fetchFromGitLab,
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
  version = "0.5.1-unstable";
  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "0f7ed9fdcfa2502d539eb7acf8232b127a219673";
    hash = "sha256-QcXZKhhk/E4Doja2k43J9updu0Hc4haRCkK4M9YADn8=";
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
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = with lib.licenses; [
      bsd3
      cc0
      gpl2Plus
    ];
    maintainers = with lib.maintainers; [ silverhadch ];
    platforms = lib.platforms.linux;
    mainProgram = "xwaylandvideobridge";
  };
})
