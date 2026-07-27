# ❄️ My NixOS config

One flake, a few machines. Each machine lives in `hosts/` with only its hardware
config; everything else is shared.

## What's where

- `flake.nix` – inputs, host discovery, dev shell discovery
- `hosts/<hostname>/` – per‑machine folder
  - `default.nix` – imports hardware config + shared config
  - `hardware-configuration.nix` – the generated one
  - `modules/` – machine‑specific bits (optional)
- `shared/configuration.nix` – imports every shared module
- `shared/modules/` – one file per topic (boot, audio, docker, networking…)
  - `overlays.nix` – custom overlays (currently: Bottles)
- `shared/users/` – all user config
  - `default.nix` – imports every user folder, global Home Manager settings
  - `<username>/`
    - `default.nix` – sets `USERNAME`/`NAME`, imports `user.nix`
    - `user.nix` – system user definition, links Home Manager
    - `home-manager.nix` – desktop/shell config (Plasma, zsh, Flatpak…)
- `pkgs/` – packages that aren't in nixpkgs (yet)
- `shells/` – one `<name>.nix` per dev shell + the `devshell` helper
- `images/` – wallpapers

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
- `rebuild-host <name>` – rebuild a specific host
- `update` – flake update + rebuild + commit + push
- `cleanup` – garbage‑collect old generations
- `update-hardware-host` – regenerate this host's hardware config
- `list-hosts` – list available machines
- `devshell list` – list dev environments
- `devshell kontainer` – enter the kontainer dev shell
- `repo-analysis` – git history stats for the repo you're standing in

## How it's glued together

```
flake.nix
├── inputs: nixpkgs, home-manager, plasma-manager, declarative-flatpak
├── devShells  ← every shells/<name>.nix
└── nixosConfigurations  ← every hosts/<hostname>/
    └── hosts/nixos-thinkpad/default.nix
        ├── imports hardware-configuration.nix
        ├── imports modules/            (machine specific)
        └── imports shared/configuration.nix
            ├── imports shared/modules/*.nix
            │   └── nix.nix imports shared/modules/overlays.nix
            └── imports shared/users/default.nix
                └── imports all user subdirectories
                    └── shared/users/<USER>/default.nix
                        └── imports ./user.nix
                            ├── defines the system user
                            └── home-manager.users.<USER> = import ./home-manager.nix
                                └── sources shells/devshell.sh
```

## Adding a user

1. Create `shared/users/<username>/` with three files:
   - `default.nix` – set username/name, import `user.nix`
   - `user.nix` – system user + home‑manager hook
   - `home-manager.nix` – actual config
2. Rebuild – it gets picked up automatically.

## Adding a dev shell

Drop a `shells/<name>.nix` in place. It shows up in `devshell list` and as
`nix develop /etc/nixos#<name>`.

## Renaming a machine

```
mv hosts/old-name hosts/new-name
run0 nixos-rebuild switch --flake /etc/nixos#new-name
```

## Updating everything

```
update
```

## License

MIT – see [LICENSE](LICENSE)
