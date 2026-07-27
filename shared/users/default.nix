{ lib, ... }:

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
  };

  # ---------------------------------------------------------------------------
  # Import all per-user modules automatically
  # ---------------------------------------------------------------------------
  imports =
    builtins.map (u: ./${u})
      (builtins.attrNames
        (lib.filterAttrs (_: type: type == "directory")
          (builtins.readDir ./.)));
}
