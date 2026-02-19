{ pkgs, inputs, ... }:

{
  environment.sessionVariables = {
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # Core
    btop
    btrfs-progs
    curl
    git
    graphviz-nox
    htop
    inotify-tools
    nano
    neovim
    vim
    wget

    # Desktop / Apps
    bottles
    discord
    firefoxpwa
    flatpak
    gimp
    github-desktop
    libreoffice-qt-fresh
    localsend
    megasync
    nixos-bgrt-plymouth
    ocrmypdf
    qbittorrent-enhanced
    spotify
    thunderbird-bin
    vlc
    webex

    # KDE
    kdePackages.appstream-qt
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kdevelop
    kdePackages.kmines
    kdePackages.kwallet-pam
    kdePackages.partitionmanager
    kdePackages.xdg-desktop-portal-kde

    # Containers / VM
    distrobox
    lilipod
    toolbox

    # Dev
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
    jq
    libclang.python
    llvmPackages.libclang
    libgcc
    meson
    msedit
    openssl
    openssl.dev
    pkg-config
    ripgrep
    shadow
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
    kdePackages.kde-dev-scripts
    kdePackages.kde-dev-utils
    kdePackages.kdev-php
    kdePackages.kdev-python

    # Fun
    cmatrix
    cowsay
    figlet
    fortune
    myman # My Package!
    nix-tree
    nyancat
    ponysay
    rig
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
        ms-python.python
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
    inputs.better-soundcloud.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
