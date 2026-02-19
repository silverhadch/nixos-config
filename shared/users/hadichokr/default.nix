{ lib, ... }:

let
  USERNAME = builtins.baseNameOf ./.;
  NAME = "Hadi Chokr";
in {
  _module.args = { inherit USERNAME NAME; };

  imports = [
    ./user.nix
  ];
}
