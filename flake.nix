{
  description = "Hadi's NixOS desktop (flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    better-soundcloud = {
      url = "github:AlirezaKJ/BetterSoundCloud";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... } @ inputs:  # Capture all inputs with @ inputs
  let
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
      inherit system;
    };

    lib = inputs.nixpkgs.lib;

    # -------------------------
    # Dynamic devShell loading
    # -------------------------
    shellFiles =
      builtins.filter
        (name: lib.hasSuffix ".nix" name)
        (builtins.attrNames (builtins.readDir ./shells));

    devShellsForSystem =
      builtins.listToAttrs (map (name: {
        name = lib.removeSuffix ".nix" name;
        value = import (./shells + "/${name}") { inherit pkgs; };
      }) shellFiles);

    # -------------------------
    # Host detection
    # -------------------------
    hosts =
      builtins.attrNames
        (builtins.readDir ./hosts);

    mkHost = hostName:
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hostName;
          inherit inputs;
        };

        modules = [
          ./hosts/${hostName}

          inputs.home-manager.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              sharedModules = [
                inputs.plasma-manager.homeModules.plasma-manager
                inputs.nix-flatpak.homeManagerModules.nix-flatpak
              ];
            };
          }
        ];
      };
  in
  {
    # -------------------------
    # NixOS systems
    # -------------------------
    nixosConfigurations =
      builtins.listToAttrs (map
        (host: {
          name = host;
          value = mkHost host;
        })
        hosts);

    # -------------------------
    # Dev shells
    # -------------------------
    devShells.${system} = devShellsForSystem;
  };
}
