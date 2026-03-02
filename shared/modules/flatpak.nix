{ pkgs, ... }:

{
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = [ "kde" ];
    extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
    ];
  };
}
