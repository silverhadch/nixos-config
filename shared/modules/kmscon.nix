{ config, pkgs, ... }:
{
  services.kmscon = {
    enable = true;
    config.hwRender = true;
    useXkbConfig = true;
    config.font-name = "Inconsolata Nerd Font Mono";
  };
}
