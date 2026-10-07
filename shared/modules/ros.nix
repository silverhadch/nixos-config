{ ... }:

# Binary caches for nix-ros-overlay (used by the `ros` dev shell).
# Has to live in the system config: the nix daemon only accepts extra
# substituters from root / trusted users, so the flake's own nixConfig
# would be ignored for a normal user.
#
# - ros.cachix.org: the official cache, but over capacity, so packages
#   are often evicted.
# - attic.iid.ciirc.cvut.cz/ros: @wentasah's Hydra-fed cache, recommended
#   by the overlay README until Cachix is sorted out (hosted in Prague).
{
  nix.settings = {
    substituters = [
      "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };
}
