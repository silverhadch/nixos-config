{ pkgs, ... }:

{
  services.flatpak.enable = true;

  xdg.portal = {
  	enable = true;
  	xdgOpenUsePortal = true;
  	config.common.default = [ "wlr" "gtk" ]; # try both
  	extraPortals = with pkgs; [
    	xdg-desktop-portal-wlr
    	xdg-desktop-portal-gtk
  	];
  };
}
