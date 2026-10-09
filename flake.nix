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

    # Prebuilt, weekly-updated nix-index database (for command-not-found + comma).
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bedrock-on-linux = {
      url = "github:Wyze3306/BedrockOnLinux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ROS 2 for Nix. Deliberately NOT following our nixpkgs: the overlay is
    # tested (and cached) against its own pinned nixpkgs, and following
    # nixos-unstable would mean building most of ROS from source.
    # Only the `ros` dev shell uses it; the system itself is untouched.
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    # PdfCraft, built from source off the tip of its default branch (`main`;
    # the repo has no `master`). `update` / `nix flake update` moves it to
    # the newest commit.
    pdfcraft = {
      url = "github:storytold/pdfcraft/main";
      flake = false;
    };

    # Optional build input for PdfCraft: Japanese UI text and Japanese text
    # in edited PDFs. Release builds always include it.
    craft-fonts = {
      url = "github:storytold/craft-fonts/main";
      flake = false;
    };
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
            inputs.nix-index-database.nixosModules.nix-index
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

      # Each shell only gets the arguments it asks for, so plain
      # `{ pkgs ? ... }:` shells keep working and shells that need flake
      # inputs (like ros.nix) can take `{ inputs, system, ... }:`.
      mkShell = name:
        let f = import ./shells/${name}.nix;
        in f (builtins.intersectAttrs (builtins.functionArgs f) {
          inherit pkgs inputs system;
        });
    in
    {
      # nixos-rebuild switch --flake /etc/nixos#<hostname>
      nixosConfigurations = lib.genAttrs hosts mkHost;

      # nix develop /etc/nixos#<shellname>
      devShells.${system} = lib.genAttrs shells mkShell;
    };
}
