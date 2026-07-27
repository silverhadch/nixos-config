{ ... }:

{
  programs = {
    appimage.enable = true;
    appimage.binfmt = true;

    firefox = {
      enable = true;
      preferences."widget.use-xdg-desktop-portal.file-picker" = 1;
      wrapperConfig.pipewireSupport = true;
    };

    fuse.userAllowOther = true;
    nix-ld.enable = true;
    steam.enable = true;
    virt-manager.enable = true;
    zsh.enable = true;
  };
}
