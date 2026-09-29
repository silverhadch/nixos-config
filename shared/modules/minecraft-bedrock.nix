{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # wine runs way smoother with it
  boot.kernelModules = [ "ntsync" ];

  # clamonacc makes the game load forever
  services.clamav.daemon.settings.OnAccessExcludePath = [
    "/home/hadichokr/.local/share/bedrock-on-linux"
  ];
}
