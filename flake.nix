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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    plasma-manager,
    nix-flatpak,
    ...
  }:
  let
    system = "x86_64-linux";

    hosts =
      builtins.attrNames
        (builtins.readDir ./hosts);

    mkHost = hostName:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hostName;
        };

        modules = [
          ./hosts/${hostName}

          home-manager.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              sharedModules = [
                plasma-manager.homeModules.plasma-manager
                nix-flatpak.homeManagerModules.nix-flatpak
              ];
            };
          }
        ];
      };
  in
  {
    nixosConfigurations =
      builtins.listToAttrs (map
        (host: {
          name = host;
          value = mkHost host;
        })
        hosts);
  };
}
