{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ podman-compose runc conmon skopeo fuse-overlayfs ];

  virtualisation = {
    containers.enable = true;
    libvirtd.enable = true;

    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    spiceUSBRedirection.enable = true;

    waydroid.enable = true;
    waydroid.package = pkgs.waydroid-nftables;
  };

  # programs.cdemu.enable = true;
}
