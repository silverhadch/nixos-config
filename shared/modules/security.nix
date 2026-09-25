{ ... }:

{
  security = {
    sudo.enable = false;

    # run0 + the real sudo shim (run0-sudo-shim) instead of a shell alias:
    # understands sudo flags like -u, -E, -i, -s, --preserve-env=…
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };

    wrappers.su.enable = false;
    wrappers.pkexec.enable = false;
  };
}
