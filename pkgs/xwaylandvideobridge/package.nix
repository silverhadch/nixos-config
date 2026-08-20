{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  pkg-config,
  qtbase,
  qtdeclarative,
  kdbusaddons,
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
  version = "0.5.2-unstable";
  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "9600ad46f91afcca878b6f8351d41fe39411dc50";
    hash = "sha256-WFklGsUPdt14P6gDX71CpCsBoO5fxbC4TgWb8IBdNfc=";
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
    kdbusaddons
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
