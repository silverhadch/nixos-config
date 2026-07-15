{ pkgs ? import <nixpkgs> {} }:

let
  qtEnv = pkgs.qt6.env "qt-cxx-env" (with pkgs.qt6; [
    qtbase
    qtdeclarative      # QtQml, QtQuick, QtQuickControls2
    qtsvg              # optional, if you use SVG icons
    qtwayland          # wayland platform plugin at runtime
  ]);

  dlopenLibraries = with pkgs; [
    openssl zlib expat fontconfig freetype libGL mesa
    wayland libxkbcommon libX11 libXcursor libXi libXrandr
    glib gdk-pixbuf cairo pango atk libdrm
  ];
in
pkgs.mkShell {
  name = "rust-dev-shell";

  nativeBuildInputs = with pkgs; [
    rust-analyzer
    rustup
    rustPlatform.bindgenHook
    pkg-config
    clang
    llvmPackages.libclang
  ];

  buildInputs = dlopenLibraries ++ [ qtEnv ] ++ (with pkgs; [
    btrfs-progs
    wayland-protocols
    dbus
  ]);

  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  # Make cxx-qt's qt-build-utils see the merged Qt tree
  QMAKE = "${qtEnv}/bin/qmake";

  env.RUSTFLAGS =
    "-C link-arg=-Wl,-rpath,${pkgs.lib.makeLibraryPath (dlopenLibraries ++ [ qtEnv ])}";

  shellHook = ''
    export RUSTUP_HOME="$HOME/.rustup"
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH"

    # Qt plugin/QML paths for running the app from the shell
    export QT_PLUGIN_PATH="${qtEnv}/lib/qt-6/plugins"
    export QML2_IMPORT_PATH="${qtEnv}/lib/qt-6/qml"

    TOOLCHAIN="stable"
    if [ -f rust-toolchain.toml ]; then
      TOOLCHAIN=$(sed -n 's/^channel *= *"\([^"]*\)".*/\1/p' rust-toolchain.toml)
    fi
    rustup toolchain install "$TOOLCHAIN" >/dev/null 2>&1 || true
    rustup override set "$TOOLCHAIN"
  '';
}
