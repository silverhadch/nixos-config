{ config, pkgs, ... }:

{
  users.users.hadichokr = {
    isNormalUser = true;
    description = "Hadi Chokr";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
      fastfetch
      home-manager
      kdePackages.kate
      neovim
      pkgs.oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };

  users.groups.libvirtd.members = [ "hadichokr" ];

  # Import hadichokr’s Home Manager config
  home-manager.users.hadichokr = import ./hadichokr-home.nix;

  # Global Home Manager options
  home-manager.backupFileExtension = "backup";
}

