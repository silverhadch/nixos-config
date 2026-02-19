{ config, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # Global Display Manager auto-login user
  # Set the default user here
  # ---------------------------------------------------------------------------
  services.displayManager.autoLogin = {
    enable = true;
    user = "hadichokr";
  };

  # ---------------------------------------------------------------------------
  # Global Home Manager defaults
  # ---------------------------------------------------------------------------
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
  };

  # ---------------------------------------------------------------------------
  # Import all per-user modules automatically
  # ---------------------------------------------------------------------------
  imports =
    builtins.map
      (u: ./${u})
      (builtins.filter
        (n: n != "default.nix")
        (builtins.attrNames (builtins.readDir ./.)));
}
