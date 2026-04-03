{ pkgs, ... }:

{
  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.liberation_ttf
    pkgs.fira-code
    pkgs.fira-code-symbols
  ];
}
