{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "kernel-dev-shell";
  nativeBuildInputs = with pkgs; [
    gcc
    makeWrapper
    binutils
    flex
    bison
    elfutils
    libelf
    openssl
    sparse
    git
    ncurses
    bc
    python3
  ];
  shellHook = ''
    echo
    echo "================================================"
    echo "Linux Kernel Development Environment"
    echo "================================================"
    echo
    echo "Current directory: $PWD"
    echo
    echo "To prepare the build infrastructure (needed once):"
    echo "  make scripts"
    echo "  make modules_prepare"
    echo
    echo "To build a staging module (example: sm750fb):"
    echo "  make M=drivers/staging/sm750fb W=1"
    echo
    echo "To run checkpatch on a file:"
    echo "  ./scripts/checkpatch.pl -f path/to/file.c"
    echo
    echo "Available tools: gcc $(gcc --version | head -n1)"
    echo "                 sparse $(sparse --version 2>/dev/null || echo 'not found')"
    echo "================================================"
  '';
}
