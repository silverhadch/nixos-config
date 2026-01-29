{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "shadow-dev-shell";

  nativeBuildInputs = with pkgs; [
    autoreconfHook
    bison
    flex
    pkg-config

    docbook_xml_dtd_45
    docbook_xsl
    itstool
    libxml2
    libxslt

    git
    gnumake

    cmocka
  ];

  buildInputs = with pkgs; [
    libxcrypt
    libbsd
    systemd
    libssh

    tcb
    linux-pam

    glibc.dev
    systemd.dev
    libssh.dev

    python313
  ];

  env = {
    XML_CATALOG_FILES = "${pkgs.docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";
    TEST_SHELL = "${pkgs.bash}/bin/bash";
  };

  shellHook = ''
    echo
    echo "Shadow development environment"
    echo

    echo "1. Clone repository:"
    echo "   git clone https://github.com/shadow-maint/shadow.git"
    echo "   cd shadow"
    echo

    echo "2. Bootstrap:"
    echo "   autoreconf -fi"
    echo

    echo "3. Configure:"
    echo "   ./configure \\"
    echo "     --with-group-name-max-length=32 \\"
    echo "     --with-bcrypt \\"
    echo "     --with-yescrypt \\"
    echo "     --with-libbsd \\"
    echo "     --with-tcb \\"
    echo "     --enable-man"
    echo

    echo "4. Build:"
    echo "   make -j\$(nproc)"
    echo

    echo "5. Test:"
    echo "   make check"
    echo

    echo "6. Clean:"
    echo "   make clean"
    echo
  '';
}
