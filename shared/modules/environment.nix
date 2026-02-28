{ pkgs, inputs, ... }:

{
  environment.sessionVariables = {
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # Core
    btop
    busybox
    btrfs-progs
    curl
    git
    graphviz-nox
    htop
    inotify-tools
    nano
    neovim
    pandoc
    vim
    wget
    xdg-desktop-portal-wlr

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
    python314Packages.ocrmypdf_16
    qbittorrent-enhanced
    spotify
    thunderbird-bin
    vlc
    webex

    # KDE
    kdePackages.filelight
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kmines
    kdePackages.partitionmanager

    # Mate
    caja
    mate-terminal
    pluma

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
    nasm
    openssl
    openssl.dev
    pkg-config
    python3
    ripgrep
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

    # Fun
    cmatrix
    cowsay
    figlet
    fortune
    myman # My Package!
    nix-tree
    nyancat
    ponysay
    prismlauncher
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
