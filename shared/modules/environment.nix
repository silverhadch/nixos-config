{ pkgs, inputs, ... }:
let
  xwaylandvideobridge = pkgs.kdePackages.callPackage ../../pkgs/xwaylandvideobridge/package.nix { };

  # Custom JDK with JavaFX
  jdkWithFX = pkgs.openjdk.override {
    enableJavaFX = true;
    # Uncomment the next line if you need WebKit support in JavaFX
    # openjfx_jdk = pkgs.openjfx.override { withWebKit = true; };
  };
in
{
  environment.sessionVariables = {
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    NIXOS_OZONE_WL = "1";
  };
  environment.systemPackages = with pkgs; [
    # Core
    android-tools
    btop
    btrfs-progs
    curl
    erofs-utils
    e2fsprogs
    git
    gptfdisk
    graphviz-nox
    grub2_efi
    htop
    inotify-tools
    libnotify
    nano
    neovim
    pandoc
    parted
    rar
    sbctl
    vim
    wget
    xorriso

    # Desktop / Apps
    arcan
    bottles
    cat9
    # firefoxpwa
    flatpak
    geogebra
    gimp
    github-desktop
    libreoffice-qt-fresh
    localsend
    megasync
    nixos-bgrt-plymouth
    python314Packages.ocrmypdf_16
    qbittorrent-enhanced
    spotify
    thunderbird-bin
    vesktop
    vlc
    # zulip

    # KDE
    kdePackages.appstream-qt
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kdevelop
    kdePackages.kmines
    kdePackages.kwallet-pam
    kdePackages.partitionmanager
    kdePackages.xdg-desktop-portal-kde
    kdePackages.skanlite
    xwaylandvideobridge

    # Oxygen
    kdePackages.oxygen
    kdePackages.oxygen-icons
    kdePackages.oxygen-sounds

    # Containers / VM
    distrobox
    lilipod
    toolbox

    # Dev
    arduino-ide
    black
    clang
    clang-tools
    cmakeWithGui
    devbox
    flatpak-builder
    gcc
    gh
    gnumake
    go
    go-md2man
    gopls
    jdt-language-server
    jq
    libclang.python
    llvmPackages.libclang
    logisim-evolution
    libgcc
    maven
    meson
    msedit
    nasm
    jdkWithFX              # ← replaced openjdk with JavaFX‑enabled JDK
    openssl
    openssl.dev
    OVMFFull
    pkg-config
    python3
    ripgrep
    scenebuilder
    shadow
    sqlite
    systemdUkify
    texlive.combined.scheme-full
    virtualenv
    wayland-utils
    xdg-utils
    zlib
    zlib.dev

    # Rust
    cargo
    clippy
    rustc
    rustfmt

    # Zig
    zig
    zls

    # KDE Dev
#     kdePackages.kde-dev-scripts
#     kdePackages.kde-dev-utils
#     kdePackages.kdev-php
#     kdePackages.kdev-python

    # Fun
    cmatrix
    cowsay
    dosbox-staging
    figlet
    fortune
    myman # My Package!
    nix-tree
    nyancat
    ponysay
    prismlauncher
    rig
    scummvm
    sl
    toilet

    # VSCode
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        dracula-theme.theme-dracula
        formulahendry.code-runner
        llvm-vs-code-extensions.lldb-dap
        llvm-vs-code-extensions.vscode-clangd
        ms-azuretools.vscode-docker
       #  ms-python.python
        ms-vscode.makefile-tools
        ms-vscode-remote.remote-ssh
        yzhang.markdown-all-in-one
      ];
    })

    # shims
    (writeShellScriptBin "vi" ''exec vim -u NONE -C "$@"'')
    (writeShellScriptBin "sudo" ''exec run0 "$@"'')
    (writeShellScriptBin "sudoedit" ''exec run0 rnano "$@"'')
    (writeShellScriptBin "doas" ''exec run0 "$@"'')
    (writeShellScriptBin "pkexec" ''exec run0 "$@"'')
    (writeShellScriptBin "su" ''
      if [ "$#" -eq 0 ]; then
        exec run0 bash
      elif [ "$1" = "-" ]; then
        exec run0 --login bash
      else
        exec run0 --user="$1" bash
      fi
    '')

    # Flakes
    # inputs.better-soundcloud.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
