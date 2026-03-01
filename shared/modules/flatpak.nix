{ pkgs, ... }:

{
  services.flatpak.enable = true;

  xdg.portal = {
  	enable = true;
  	xdgOpenUsePortal = true;
  	config.common.default = [ "hyprland" ];
  	extraPortals = with pkgs; [
    	xdg-desktop-portal-hyprland
  	];
  };
}
