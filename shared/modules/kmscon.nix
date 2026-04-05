{ config, pkgs, ... }:

{
  services.kmscon = {
    enable = true; # Enables kmscon on all TTYs

    # Use GPU hardware acceleration for faster rendering
    hwRender = true;

    # Sync keyboard layout with X11 settings
    useXkbConfig = true;

    # Specify fonts
    fonts = [
      { name = "Inconsolata Nerd Font"; package = pkgs.nerd-fonts.inconsolata; }
      { name = "Fira Code"; package = pkgs.fira-code; }
    ];
  };
}
