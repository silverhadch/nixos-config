{ config, pkgs, ... }:
let
  # MZ wrapper that bails out if it's actually a Windows PE binary
  dosExeWrapper = pkgs.writeShellScript "dosbox-exe-binfmt" ''
    ${pkgs.python3}/bin/python3 -c "
import sys, struct
with open(sys.argv[1], 'rb') as f:
    if f.read(2) != b'MZ': sys.exit(0)
    f.seek(0x3c)
    off = struct.unpack('<I', f.read(4))[0]
    f.seek(off)
    sys.exit(1 if f.read(4) == b'PE\x00\x00' else 0)
" "$1" || { echo "Windows PE binary, not invoking dosbox" >&2; exit 1; }
    exec ${pkgs.dosbox}/bin/dosbox "$1"
  '';

  dosBatWrapper = pkgs.writeShellScript "dosbox-bat-binfmt" ''
    exec ${pkgs.dosbox}/bin/dosbox "$1"
  '';
in
{
  boot.binfmt = {
    preferStaticEmulators = true;
    registrations = {
      dos-exe = {
        recognitionType = "magic";
        magicOrExtension = ''\x4d\x5a'';
        mask = ''\xff\xff'';
        interpreter = "${dosExeWrapper}";
      };
      dos-bat = {
        recognitionType = "extension";
        magicOrExtension = "BAT";
        interpreter = "${dosBatWrapper}";
      };
      dos-bat-lc = {
        recognitionType = "extension";
        magicOrExtension = "bat";
        interpreter = "${dosBatWrapper}";
      };
    };
  };
  programs.java.binfmt.enable = true;
}
