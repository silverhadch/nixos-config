{ pkgs, ... }:

{
  virtualisation = {
    containers.enable = true;
    libvirtd.enable = true;

    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    docker.enable = true;
    spiceUSBRedirection.enable = true;

    waydroid.enable = true;
    waydroid.package = pkgs.waydroid-nftables;
  };

  systemd.services.waydroid-container.enable = true;
}
