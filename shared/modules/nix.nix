{
  nix = {
    gc = {
      automatic = true;
      dates = "hourly";
      options = "--delete-older-than 5d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./overlays.nix;
  };
}
