# PdfCraft built from source. `src` is the `pdfcraft` flake input (tip of
# main), `craftFonts` the optional `craft-fonts` input; see flake.nix.
{
  lib,
  rustPlatform,
  src,
  craftFonts ? null,
  cmake,
  perl,
  pkg-config,
  patchelf,
  # dlopen()ed at runtime by eframe/winit/wgpu, so never in DT_NEEDED
  dbus,
  libGL,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libxkbcommon,
  vulkan-loader,
  wayland,
}:

let
  cargoToml = lib.importTOML "${src}/Cargo.toml";
  appId = "ai.storyteller.pdfcraft";
  date = src.lastModifiedDate or "19700101000000";
  isoDate = "${lib.substring 0 4 date}-${lib.substring 4 2 date}-${lib.substring 6 2 date}";

  runtimeLibs = [
    dbus
    libGL
    libX11
    libXcursor
    libXi
    libXrandr
    libxkbcommon
    vulkan-loader
    wayland
  ];
in
rustPlatform.buildRustPackage {
  pname = "pdfcraft";
  version = "${cargoToml.workspace.package.version}-unstable-${isoDate}";

  inherit src;

  # The lock file comes straight from the checkout, so following main never
  # needs a cargoHash bump (Cargo.lock has no git dependencies).
  cargoLock.lockFile = "${src}/Cargo.lock";

  # aws-lc-sys (signatures) builds C/asm; cmake is for it only, not for us.
  nativeBuildInputs = [ cmake perl pkg-config patchelf ];
  dontUseCmakeConfigure = true;

  buildInputs = runtimeLibs;

  cargoBuildFlags = [ "-p" "pdfcraft" "-p" "pdfcraft-cli" ];

  # The test suite renders whole corpora; far too slow for a system rebuild.
  doCheck = false;

  env = {
    PDFCRAFT_BUILD_SHA = src.rev or "";
    PDFCRAFT_BUILD_DATE = isoDate;
  } // lib.optionalAttrs (craftFonts != null) {
    CRAFT_FONTS_DIR = "${craftFonts}";
  };

  # Same layout as upstream's packaging/linux/package.sh.
  postInstall = ''
    install -Dm644 packaging/linux/${appId}.desktop $out/share/applications/${appId}.desktop
    install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
    mkdir -p $out/share/metainfo
    sed -e "s/@VERSION@/${cargoToml.workspace.package.version}/g" -e "s/@DATE@/${isoDate}/g" \
      packaging/linux/${appId}.metainfo.xml.in > $out/share/metainfo/${appId}.metainfo.xml
    mkdir -p $out/share/icons
    cp -R assets/app-icon/hicolor $out/share/icons/
  '';

  postFixup = ''
    for bin in $out/bin/pdfcraft $out/bin/pdfcraft-cli; do
      patchelf --add-rpath ${lib.makeLibraryPath runtimeLibs} "$bin"
    done
  '';

  meta = {
    description = "Open-source PDF workbench: read, organize, combine, split and secure PDFs";
    homepage = "https://github.com/storytold/pdfcraft";
    license = with lib.licenses; [ mit asl20 ] ++ lib.optional (craftFonts != null) ofl;
    platforms = lib.platforms.linux;
    mainProgram = "pdfcraft";
  };
}
