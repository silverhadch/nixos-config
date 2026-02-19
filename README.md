# ❄ NixOS Flake Desktop Configuration

One desktop configuration, multiple machines. Each machine is a folder under `hosts/` with only hardware-specific differences.

## File Guide

| File | Purpose |
|------|---------|
| `flake.nix` | Root – imports inputs, discovers hosts |
| `hosts/[hostname]/default.nix` | Machine entry point |
| `hosts/[hostname]/hardware-configuration.nix` | Auto‑generated hardware config |
| `shared/configuration.nix` | Core system config (common to all hosts) |
| `shared/overlays.nix` | Nixpkgs overlays (e.g., KWallet portal fix, Bottles, Webex) |
| `shared/users/default.nix` | **Auto‑imports all users** + global Home Manager defaults |
| `shared/users/<USERNAME>/` | User directory for **<USERNAME>** |
| `shared/users/<USERNAME>/default.nix` | User‑specific `_module.args` and imports `./user.nix` |
| `shared/users/<USERNAME>/user.nix` | System user definition (groups, subuids) + Home Manager integration |
| `shared/users/<USERNAME>/home-manager.nix` | Desktop & shell config (dconf, distrobox, flatpak, git, konsole, plasma, zsh) |
| `shells/devshell.sh` | Dev shell manager script |
| `shells/*.nix` | Dev environments (e.g., `kontainer.nix`) |
| `images/wallpaper.svg` | Desktop wallpaper |

## Quick Start (New Machine)

1. Install NixOS normally.
2. Move the generated hardware config:
   ```bash
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
4. Build the system:
   ```bash
   run0 nixos-rebuild switch --flake /etc/nixos#<hostname>
   ```

## Key Commands

```bash
rebuild           # Rebuild current host
update            # Update inputs and rebuild
list-hosts        # Show available machines
devshell list     # List dev environments
devshell kontainer # Container development
```

## File Dependencies

```
flake.nix
├── Imports: nixpkgs, home-manager, plasma-manager, nix-flatpak, better-soundcloud
└── Discovers: hosts/ directory
    └── hosts/nixos-thinkpad/default.nix
        ├── imports: hardware-configuration.nix
        └── imports: shared/configuration.nix
            ├── imports: shared/overlays.nix
            └── imports: shared/users/default.nix   (global Home Manager options)
                └── imports: all user subdirectories
                    └── shared/users/<USERNAME>/default.nix
                        └── imports: ./user.nix
                            ├── users.users.<USERNAME> (system user)
                            └── home-manager.users.<USERNAME> = import ./home-manager.nix
                                ├── sources: shells/devshell.sh
                                ├── references: shells/kontainer.nix
                                └── uses: images/wallpaper.svg
```

## Management

### Add a New User
1. Create a new directory under `shared/users/` with the username.
2. Inside, create:
   - `default.nix` (sets `USERNAME` and `NAME`, imports `user.nix`)
   - `user.nix` (system user definition, Home Manager integration)
   - `home-manager.nix` (user’s desktop/shell configuration)
3. Rebuild – the new user will be picked up automatically.

### Rename Machine
```bash
mv hosts/old-name hosts/new-hostname
run0 nixos-rebuild switch --flake /etc/nixos#new-hostname
```

### Update Everything
```bash
cd /etc/nixos
nix flake update
rebuild
```

### Regenerate Hardware
```bash
update-hardware-host
```

## License

MIT – see [LICENSE](LICENSE)
