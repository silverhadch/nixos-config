{ config, pkgs, ... }:
{
  services.kmscon = {
    enable = true;
    hwRender = true;
    useXkbConfig = true;
    config.font-name = "Inconsolata Nerd Font Mono";
  };
}
