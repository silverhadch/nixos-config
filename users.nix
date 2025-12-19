{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Home Manager (global integration)
  # ---------------------------------------------------------------------------
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  home-manager.users.hadichokr = {
    imports = [ ./hadichokr-home.nix ];
  };

  # ---------------------------------------------------------------------------
  # Users & groups
  # ---------------------------------------------------------------------------
  users.groups.libvirtd.members = [ "hadichokr" ];

  users.users.hadichokr = {
    isNormalUser = true;
    description = "Hadi Chokr";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" ];

    subUidRanges = [
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      { startGid = 100000; count = 65536; }
    ];

    packages = with pkgs; [
      fastfetch
      home-manager
      kdePackages.kate
      neovim
      oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };
}
