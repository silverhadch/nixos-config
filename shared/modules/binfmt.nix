{ config, pkgs, ... }:

{
  boot.binfmt = {
    preferStaticEmulators = true;
    registrations = {
      dos = {
        # Recognise DOS MZ executables by their magic bytes
        recognitionType = "magic";
        magicOrExtension = ''\x4d\x5a''; # MZ header
        mask = ''\xff\xff'';             # Match both bytes
        # Use DOSBox as the interpreter
        interpreter = "${pkgs.dosbox}/bin/dosbox";
      };
    };
  };

  # Java
  programs.java.binfmt.enable = true;
}
