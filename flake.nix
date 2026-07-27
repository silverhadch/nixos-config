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
      inputs.home-manager.follows = "home-manager";
    };

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      lib = inputs.nixpkgs.lib;
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # Every directory below ./hosts is one machine.
      hosts =
        builtins.attrNames
          (lib.filterAttrs (_: type: type == "directory")
            (builtins.readDir ./hosts));

      # Every ./shells/<name>.nix is one dev shell.
      shells =
        map (lib.removeSuffix ".nix")
          (builtins.attrNames
            (lib.filterAttrs
              (name: type: type == "regular" && lib.hasSuffix ".nix" name)
              (builtins.readDir ./shells)));

      mkHost = hostName:
        lib.nixosSystem {
          inherit system;

          specialArgs = { inherit hostName inputs; };

          modules = [
            ./hosts/${hostName}
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.declarative-flatpak.homeModules.default
                ];
              };
            }
          ];
        };

      mkShell = name: import ./shells/${name}.nix { inherit pkgs; };
    in
    {
      # nixos-rebuild switch --flake /etc/nixos#<hostname>
      nixosConfigurations = lib.genAttrs hosts mkHost;

      # nix develop /etc/nixos#<shellname>
      devShells.${system} = lib.genAttrs shells mkShell;
    };
}
