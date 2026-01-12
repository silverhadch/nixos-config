### ❄️ NixOS Flake Desktop Config

One desktop config, multiple machines.
Each machine = one folder under `hosts/`.

---

## Files

- flake.nix  
  Wires everything together.  
  Defines inputs, exposes all hosts, passes `hostName`.

- hosts/`hostname`/default.nix  
  Machine entry point.  
  Imports hardware + shared config.

- hosts/`hostname`/hardware-configuration.nix  
  Generated per machine.  
  Disks, filesystems, kernel modules only.

- shared/configuration.nix  
  Full system desktop config (Plasma, audio, network, Flatpak, packages, etc).  
  Uses `hostName` from the flake.

- shared/users/users.nix  
  System users + Home Manager integration.

- shared/users/hadichokr-home-manager.nix  
  Pure Home Manager config (shell, Plasma, apps, aliases).

---

## New machine (fresh install)

1. Install NixOS normally
2. Move the hardware config:
   ```
   mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/<hostname>/
   ```
3. Delete the old configuration.nix
4. Create hosts/`hostname`/default.nix:
   ```
   {
     imports = [
       ./hardware-configuration.nix
       ../../shared/configuration.nix
     ];
   }
   ```
5. Build:
   ```
   run0 nixos-rebuild switch --flake /etc/nixos#<hostname>
   ```

---

## Rename a machine

```
mv hosts/old-name hosts/new-name
git add .
run0 nixos-rebuild switch --flake /etc/nixos#new-name
```

---

## Aliases

```
rebuild='run0 nixos-rebuild switch --flake /etc/nixos#$(hostnamectl hostname)'
update='run0 nixos-rebuild switch --upgrade --flake /etc/nixos#$(hostnamectl hostname)'
list-hosts='ls /etc/nixos/hosts'
rebuild-host='run0 nixos-rebuild switch --flake /etc/nixos#$1'
```

---

## Update inputs

```
nix flake update
```

---

## License

MIT
