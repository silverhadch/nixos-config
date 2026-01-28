{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "kontainer-dev-shell";

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    git
  ];

  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qtdeclarative

    kdePackages.appstream-qt
    kdePackages.extra-cmake-modules
    kdePackages.kirigami
    kdePackages.kirigami-addons
    kdePackages.ki18n
    kdePackages.kcoreaddons
    kdePackages.kirigami-addons
    kdePackages.qqc2-desktop-style
    kdePackages.kiconthemes
    kdePackages.kio

    distrobox
    flatpak-builder
  ];

  shellHook = ''
    echo
    echo "Kontainer Kirigami dev environment"
    echo "--------------------------------"
    echo
    echo "⚠  NOTE about Nix builds:"
    echo
    echo "  ecm_find_qmlmodule(org.kde.kirigami REQUIRED)"
    echo "  fails under Nix because QML modules are not"
    echo "  discoverable at configure time."
    echo
    echo "  For local Nix builds, temporarily change it to:"
    echo
    echo "    ecm_find_qmlmodule(org.kde.kirigami)"
    echo
    echo "  and revert before committing."
    echo
    echo "--------------------------------"
    echo "CMake build:"
    echo
    echo "  cmake -B build -S . -G Ninja \\"
    echo "    -DCMAKE_BUILD_TYPE=Release"
    echo
    echo "  cmake --build build"
    echo
    echo "--------------------------------"
    echo "Flatpak build:"
    echo
    echo "  flatpak-builder \\"
    echo "    --user --install --force-clean \\"
    echo "    build-dir io.github.DenysMb.Kontainer.json"
    echo
    echo "--------------------------------"
    echo "Qt: ${pkgs.qt6.qtbase.version}"
    echo "CMake: $(cmake --version | head -n1)"
    echo
  '';
}
