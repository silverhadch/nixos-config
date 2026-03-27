{ config, pkgs, ... }:

{
  boot.binfmt.registrations = {
    dos = {
      # Recognise DOS MZ executables by their magic bytes
      recognitionType = "magic";
      magicOrExtension = ''\x4d\x5a''; # MZ header
      mask = ''\xff\xff'';             # Match both bytes
      # Use DOSBox as the interpreter
      interpreter = "${pkgs.dosbox}/bin/dosbox";
      # Wrap in a shell to pass additional arguments like -exit
      wrapInterpreterInShell = true;
    };
  };
}
