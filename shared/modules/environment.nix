{ pkgs, ... }:
let
  xwaylandvideobridge = pkgs.kdePackages.callPackage ../../pkgs/xwaylandvideobridge/package.nix { };

  # openjdk with JavaFX enabled.
  # For WebKit support in JavaFX, add:
  #   openjfx_jdk = pkgs.openjfx.override { withWebKit = true; };
  jdkWithFX = pkgs.openjdk.override {
    enableJavaFX = true;
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
    e2fsprogs
    erofs-utils
    git
    gptfdisk
    graphviz-nox
    grub2_efi
    htop
    inotify-tools
    libnotify
    nano
    pandoc
    parted
    rar
    vim
    wget
    xorriso

    # Desktop / Apps
    arcan
    bottles
    cat9
    geogebra
    gimp
    github-desktop
    libreoffice-qt-stable
    localsend
    megasync
    nheko
    ocrmypdf
    qbittorrent-enhanced
    spotify
    thunderbird-bin
    vesktop
    vlc
    zulip

    # KDE
    kdePackages.appstream-qt
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kdevelop
    kdePackages.kmines
    kdePackages.kwallet-pam
    kdePackages.partitionmanager
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
    jdkWithFX
    jdt-language-server
    jq
    libclang.python
    libgcc
    llvmPackages.libclang
    logisim-evolution
    maven
    meson
    msedit
    nasm
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
    texliveFull
    virtualenv
    wayland-utils
    xdg-utils
    zlib
    zlib.dev

    # Rust
    cargo
    clippy
    rustc
    rust-analyzer
    rustfmt

    # Zig
    zig
    zls

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
  ];
}
