{ pkgs ? import <nixpkgs> {} }:

let
  dlopenLibraries = with pkgs; [
    openssl
    zlib
    expat
    fontconfig
    freetype
    libGL
    mesa
    wayland
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    glib
    gdk-pixbuf
    cairo
    pango
    atk
    libdrm
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

  buildInputs = dlopenLibraries ++ (with pkgs; [
    btrfs-progs
    wayland-protocols
    dbus
  ]);


  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  env.RUSTFLAGS =
    "-C link-arg=-Wl,-rpath,${pkgs.lib.makeLibraryPath dlopenLibraries}";

  shellHook = ''
    export RUSTUP_HOME="$HOME/.rustup"
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH"

    TOOLCHAIN="stable"
    if [ -f rust-toolchain.toml ]; then
      TOOLCHAIN=$(sed -n 's/^channel *= *"\([^"]*\)".*/\1/p' rust-toolchain.toml)
    fi

    rustup toolchain install "$TOOLCHAIN" >/dev/null 2>&1 || true
    rustup override set "$TOOLCHAIN"

    echo
    echo "Rust dev shell ready"
    echo "→ Toolchain: $TOOLCHAIN"
    echo "→ RUSTFLAGS includes rpath for native libs"
    echo "→ Wayland / GL / GTK fully wired"
    echo
  '';
}
