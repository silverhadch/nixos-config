# ❄️ My NixOS config

One flake, a few machines. Each machine lives in `hosts/` with only its hardware config.

## What's where

- `flake.nix` – root, imports stuff, finds hosts
- `hosts/<hostname>/` – per‑machine folder
  - `default.nix` – just imports hardware + shared config
  - `hardware-configuration.nix` – the generated one
- `shared/configuration.nix` – core system config (common to all)
- `shared/overlays.nix` – custom overlays (KWallet portal, Bottles, Webex…)
- `shared/users/` – all user config
  - `default.nix` – imports every user folder, global Home Manager settings
  - `shared/users/<username>/` – one folder per user
    - `default.nix` – sets username/name, imports `user.nix`
    - `user.nix` – system user definition, links Home Manager
    - `home-manager.nix` – actual desktop/shell config (Plasma, zsh, etc.)
- `shells/` – dev shell stuff
- `images/wallpaper.svg` – wallpaper

## New machine

1. Install NixOS normally.
2. Move the generated hardware config:
   ```
   mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/<hostname>/
   ```
3. Create `hosts/<hostname>/default.nix`:
   ```nix
   { ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../shared/configuration.nix
     ];
   }
   ```
4. Build:
   ```
   git add . && run0 nixos-rebuild switch --flake /etc/nixos#<hostname>
   ```

## Commands I use

- `rebuild` – rebuild current host
- `update` – nix flake update + rebuild
- `list-hosts` – list available machines
- `devshell list` – list dev environments
- `devshell kontainer` – start kontainer dev shell

## How it's glued together

```
flake.nix
├── imports nixpkgs, home-manager, plasma-manager, nix-flatpak, better-soundcloud
└── discovers hosts/ directory
    └── hosts/nixos-thinkpad/default.nix
        ├── imports hardware-configuration.nix
        └── imports shared/configuration.nix
            ├── imports shared/overlays.nix
            └── imports shared/users/default.nix
                └── imports all user subdirectories
                    └── shared/users/<USER>/default.nix
                        └── imports ./user.nix
                            ├── defines system user
                            └── home-manager.users.<USER> = import ./home-manager.nix
                                ├── uses shells/devshell.sh
                                ├── references shells/kontainer.nix
                                └── uses images/wallpaper.svg
```

## Adding a user

1. Create `shared/users/<username>/` with three files:
   - `default.nix` – set username/name, import `user.nix`
   - `user.nix` – system user + home‑manager hook
   - `home-manager.nix` – actual config
2. Rebuild – it gets picked up automatically.

## Renaming a machine

```
mv hosts/old-name hosts/new-name
run0 nixos-rebuild switch --flake /etc/nixos#new-name
```

## Updating everything

```
cd /etc/nixos
nix flake update
rebuild
```

## Regenerate hardware config

```
update-hardware-host
```

## License

MIT – see [LICENSE](LICENSE)
