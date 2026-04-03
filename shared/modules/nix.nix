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
    config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];

    overlays = import ./overlays.nix;
  };
}
