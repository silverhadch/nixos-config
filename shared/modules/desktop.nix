{ pkgs, ... }:

{
  hardware.graphics.enable = true;

  services.displayManager.defaultSession = "budgie-desktop";

  services.desktopManager.budgie.enable = true;
}
