{ pkgs, ... }:

{
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin pkgs.sane-airscan ];
  services.printing = {
    enable = true;
    drivers = with pkgs; [
        cups-browsed
        cups-filters
    ];
  };
}
