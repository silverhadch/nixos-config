{ config, lib, pkgs, ... }:

{
  # ── Overlay: patch cdesktopenv to skip the broken doc build ───────────────
  #
  # CDE 2.5.3's doc indexer (dtsrload) has a buffer overflow that glibc's
  # stack-smashing protection kills at build time.  Stripping the 'doc'
  # subdirectory from the top-level Makefile bypasses it entirely — the
  # CDE desktop itself is unaffected; you just won't have offline HTML docs.
  nixpkgs.overlays = [
    (final: prev: {
      cdesktopenv = prev.cdesktopenv.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          # Remove 'doc' from the SUBDIRS list so dtsrload is never invoked.
          sed -i 's/ doc / /' Makefile.am || true
          sed -i 's/ doc$//'   Makefile.am || true
          # Also patch the generated Makefile in case autoconf already ran.
          sed -i 's/ doc / /' Makefile     || true
          sed -i 's/ doc$//'  Makefile     || true
        '';
      });
    })
  ];

  # ── X server ──────────────────────────────────────────────────────────────
  services.xserver = {
    enable = true;

    desktopManager.cde = {
      enable = true;

      extraPackages = with pkgs; [
        xclock
        bitmap
        xlsfonts
        xfd
        xrefresh
        xload
        xwininfo
        xdpyinfo
        xwd
        xwud
      ];
    };
  };

  # ── Services CDE depends on ───────────────────────────────────────────────
  # CDE uses ONC-RPC and xinetd for its calendar manager daemon (cmsd).
  services.rpcbind.enable = true;
  services.xinetd.enable  = true;

  # ── Fonts ─────────────────────────────────────────────────────────────────
  # CDE was designed for Motif/X11 bitmap fonts.
  fonts.packages = with pkgs; [
    font-bitstream-75dpi
    font-bitstream-100dpi
    font-misc-misc
    font-cursor-misc
    font-adobe-75dpi
    font-adobe-100dpi
  ];

  fonts.enableDefaultPackages = true;
  fonts.fontconfig.enable     = true;

  # ── System packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cdesktopenv   # the CDE binaries themselves
    xterm         # fallback terminal in case dtterm misbehaves
    motif         # Motif widget library (required at runtime)
  ];
}
