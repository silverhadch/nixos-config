# NixOS Configuration

This directory contains the full declarative configuration for this system.  
All configs are kept in `/etc/nixos` for simplicity.

## File layout

- **configuration.nix**  
  Main system configuration (imports hardware config, Home Manager, users).

- **hardware-configuration.nix**  
  Auto-generated hardware configuration from NixOS install.

- **users.nix**  
  Defines all system users and groups, plus links each user to their Home Manager configuration.  
  This is the place to add new users in the future.

- **hadichokr-home.nix**  
  Home Manager configuration for the user `hadichokr`.  
  Contains user-level packages, aliases, Plasma config, Flatpak setup, etc.

## Aliases (Zsh)

Inside the Home Manager config (`hadichokr-home.nix`) these aliases are defined:

- `rebuild` → `sudo nixos-rebuild switch`  
- `update` → `sudo nixos-rebuild switch --upgrade`  
- `update-home` → `home-manager switch`  

So you can quickly rebuild or update either the whole system or just your Home Manager config.

## How to add a new user

1. Add a new `users.users.<name>` entry in `users.nix`.  
2. Create a `<name>-home.nix` file for their Home Manager config.  
3. Import it in `users.nix` under `home-manager.users.<name>`.  

Example:

```nix
users.users.alice = {
  isNormalUser = true;
  extraGroups = [ "wheel" ];
};

home-manager.users.alice = import ./alice-home.nix;
```

This keeps system-wide user accounts separate from their individual Home Manager configs.
