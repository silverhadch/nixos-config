# ❄ NixOS Configuration

This repository contains my personal **NixOS + Home Manager** setup.
It is fully declarative, slightly over-engineered on purpose, and tuned for a **Plasma 6 / Wayland** workstation with containers, virtualization, Flatpak, and a reproducible dev environment.

---

## 📂 Repository Layout

* **`configuration.nix`** – system-wide NixOS configuration
* **`hardware-configuration.nix`** – auto-generated hardware settings
* **`users.nix`** – users, groups, and Home Manager integration
* **`hadichokr-home.nix`** – Home Manager configuration for `hadichokr`
* **`pkgs/`** – custom / overridden packages

  * `fu-vpn/` – legacy custom VPN package (currently unused)

---

## 🚀 System Features

### Boot & Kernel

* `systemd-boot` with EFI variables enabled
* Latest kernel (`linuxPackages_latest`)
* Quiet boot with Plymouth (`bgrt` theme)
* Limited boot entries (keeps last 3)

### Nix & System Maintenance

* Automatic garbage collection (hourly, keeps 5 days)
* Store auto-optimisation enabled
* `nix-command` + `flakes` enabled
* Automatic system upgrades (no forced reboot)
* `nix-ld` enabled for running non-Nix binaries

### Storage

* Encrypted swapfile (`/var/lib/swapfile`, 16 GiB)
* Randomized swap encryption on each boot

---

## 🌐 Networking

* **NetworkManager** enabled
* **Cisco AnyConnect VPN** via `networkmanager-openconnect`

  * FU Berlin VPN profile declared declaratively
  * Custom user-agent & OS spoofing for Cisco compatibility
* IPv6 disabled for the VPN profile

---

## 🖥 Desktop & UX

* **Plasma 6** (Wayland-first)
* **SDDM** display manager (Wayland enabled)
* PipeWire audio stack (ALSA + PulseAudio compatibility)
* Bluetooth enabled with:

  * FastConnectable
  * Battery reporting for supported devices

### Portals & App Support

* Flatpak enabled (system + Home Manager)
* XDG portals:

  * KDE + GTK portals
  * File picker forced through portals
* AppImage support via `binfmt`

---

## 📦 Containers & Virtualization

### Containers

* Podman as the primary container engine
* Docker-compatible CLI (`docker` → podman)
* DNS-enabled default podman network
* Distrobox integration

### Virtualization

* libvirt + virt-manager
* Spice USB redirection
* Waydroid enabled (nftables backend)

---

## 🌍 Locale & Input

* Locale: `de_DE.UTF-8`
* Timezone: `Europe/Berlin`
* Keyboard layout: `de` (console + X11/Wayland)

---

## 🧑 User Environment (Home Manager)

Managed in **`hadichokr-home.nix`**.

### Shell & CLI

* **Zsh + Oh My Zsh**
* Autosuggestions & syntax highlighting (Nix-installed)
* Extensive aliases for:

  * NixOS rebuilds
  * Home Manager
  * Git
  * Distrobox
* `fastfetch` runs on shell startup

### Development Toolbox

A reproducible **Debian Unstable** dev container via **Distrobox**:

* Podman-backed
* Auto-pull latest image
* Preinstalled toolchain:

  * C / C++ (gcc, cmake, meson, ninja)
  * Go
  * Python
  * XML / DocBook tooling
  * systemd headers

This keeps the host clean while still allowing heavy development.

### Plasma Configuration

Configured declaratively via **plasma-manager**:

* Breeze Dark look & feel
* Konqi wallpaper (blurred background)
* Wobbly windows + translucency
* Virtual desktops: 2×2 grid
* Screenshot shortcut: **F12** (Spectacle)

### Flatpak (User)

* Daily auto-updates
* Global Wayland-only policy (no X11 fallback)
* Cursor & GTK theme fixes
* Selected apps:

  * Whatsie
  * OBS Studio
  * Gear Lever
  * NeoChat
  * Zeal
  * SuperTux Party

---

## 🧩 Package Highlights

### System Packages

* Browsers & communication: Firefox, Thunderbird, Webex, Discord
* Office & media: LibreOffice, VLC, Spotify
* Dev & tooling: Git, GCC, Clang tools, Go, Meson, CMake
* KDE tooling: KDevelop, Partition Manager, KDE dev utils
* Fun & terminal toys: cowsay, cmatrix, ponysay, nyancat

### Overlays

* **Bottles** patched to remove warning popups
* **Webex** wrapped to force X11 for stability under Wayland

---

## 🔄 Common Commands

Rebuild system:

```sh
sudo nixos-rebuild switch
```

Upgrade system:

```sh
sudo nixos-rebuild switch --upgrade
```

Home Manager only:

```sh
home-manager -f /etc/nixos/hadichokr-home.nix switch
```

Full update:

```sh
sudo nixos-rebuild switch --upgrade && home-manager -f /etc/nixos/hadichokr-home.nix switch
```

---

## 📌 Versions

* **System stateVersion**: `25.11`
* **Home Manager stateVersion**: `25.05`
* **Primary user**: `hadichokr`

---

## 📜 License

Reuse anything you like.
Just remember: declarative power cuts both ways — read before you rebuild.

❄ Built with **NixOS**, **Home Manager**, and a healthy distrust of mutable systems.
