{ ... }:

{
  nix = {
    gc = {
      automatic = true;
      # Hourly GC deleted store paths a long-running Plasma session still
      # needed (missing icons) and threw away half-finished builds.
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      # max-jobs x cores = max compiler threads. 16 x 16 (auto/0) made rustc
      # eat all RAM; 4 x 4 still keeps all 16 threads busy.
      # Note: builds started as root (nixos-rebuild, autoUpgrade) don't go
      # through nix-daemon, so the limits in systemd.nix never applied to them.
      max-jobs = 4;
      cores = 4;
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    config.permittedInsecurePackages = [
      "olm-3.2.16"
      "pnpm-10.29.2"
    ];

    overlays = import ./overlays.nix;
  };
}
