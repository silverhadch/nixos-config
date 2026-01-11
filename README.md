# NixOS Configuration

Personal NixOS + Home Manager setup for a Plasma 6 / Wayland workstation.
Fully declarative, reproducible, and cleanly split between system and user space.

---

## Layout

- configuration.nix – system configuration
- users.nix – users, groups, Home Manager integration
- hadichokr-home.nix – Home Manager config
- pkgs/ – overlays and custom packages (unused right now)

---

## System Overview

- Boot: systemd-boot (EFI), Plymouth (bgrt), quiet boot
- Kernel: latest stable
- Nix:
  - automatic GC (hourly, keep 5 days)
  - store optimisation
  - nix-command + flakes
  - auto-upgrades (no forced reboot)
  - nix-ld enabled
- Storage: encrypted swapfile (16 GiB, random key per boot)

---

## Desktop & Audio

- Plasma 6 (Wayland-first)
- SDDM (Wayland enabled)
- PipeWire (ALSA + Pulse compatibility)
- Bluetooth with battery reporting

---

## Networking

- NetworkManager
- Declarative Cisco AnyConnect VPN (FU Berlin)
- IPv6 disabled for VPN profile

---

## Containers & Virtualization

- Podman (docker-compatible)
- Distrobox enabled
- libvirt + virt-manager
- Waydroid (nftables backend)
- Spice USB redirection

---

## Locale & Input

- Locale: de_DE.UTF-8
- Timezone: Europe/Berlin
- Keyboard: de (console + graphical)

---

## User Environment (Home Manager)

Defined in hadichokr-home.nix.
No user packages in system config.

### Shell

- Zsh + Oh My Zsh
- Autosuggestions + syntax highlighting (Nix-managed)
- Aliases for NixOS, Home Manager, Git, Distrobox
- fastfetch on shell startup

### Development

- Debian Unstable toolbox via Distrobox
- Podman-backed, auto-pull
- Toolchains: C/C++, Go, Python, XML/DocBook, systemd headers
- Host stays clean, dev stays isolated

### Plasma (Declarative)

- Breeze Dark
- Konqi wallpaper (blurred)
- Wobbly windows + translucency
- Virtual desktops: 2×2
- Spectacle on F12

### Flatpak (User)

- Daily auto-updates
- Wayland-only policy
- Cursor and GTK theme fixes
- Small, curated app set

---

## Overlays

- Bottles: warning popup removed
- Webex: forced X11 for Wayland stability

---

## Versions

- System stateVersion: 25.11
- Home Manager stateVersion: 26.05
- User: hadichokr

---

## License

Do whatever you want with it.
