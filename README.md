# ❄️ NixOS Configuration

This repository contains my personal NixOS system configuration.  
It is fully declarative, using **NixOS modules**, **Home Manager**, and extra tooling for **Flatpak** and **Plasma** customization.  

---

## 📂 Repository Layout

- **`configuration.nix`** – main system configuration  
- **`hardware-configuration.nix`** – auto-generated hardware settings  
- **`users.nix`** – user definitions + Home Manager integration  
- **`hadichokr-home.nix`** – Home Manager configuration for my user  

---

## 🚀 Features

- **Boot & Kernel**
  - `systemd-boot` with EFI support  
  - Latest Linux kernel (`linuxPackages_latest`)  
  - Plymouth splash with `bgrt` theme  

- **System Tweaks**
  - Daily garbage collection (`--delete-older-than 5d`)  
  - `nix-command` and `flakes` enabled  
  - Auto system upgrades (without reboot)  

- **Desktop**
  - **Plasma 6** with SDDM (Wayland enabled by default)  
  - Plasma customization via [plasma-manager](https://github.com/nix-community/plasma-manager)  
  - Dark theme, Konqi wallpaper, wobbly windows & glide animations  

- **User Environment**
  - **Home Manager** for user configuration  
  - **Zsh + Oh My Zsh** with autosuggestions, syntax highlighting  
  - Aliases for rebuild/update workflows  

- **Networking & Locale**
  - NetworkManager enabled  
  - Hostname: `nixos`  
  - Locale: `de_DE.UTF-8`  
  - Timezone: `Europe/Berlin`  

- **Audio**
  - PipeWire (with ALSA + PulseAudio support)  
  - RealtimeKit enabled  

- **Virtualization**
  - libvirt + virt-manager  
  - Spice USB redirection  
  - Waydroid enabled  

- **Applications**
  - System: `git`, `vim`, `htop`, `btop`, `curl`, `wget`  
  - KDE apps: Kate, KCalc, KDevelop, Partition Manager, NeoChat  
  - Productivity: LibreOffice, Thunderbird, GitHub Desktop, MEGAsync  
  - Gaming: Steam, SuperTux, SuperTuxKart  
  - Media: Spotify, VLC, qBittorrent Enhanced, Discord  
  - Flatpak support (extra apps installed via Home Manager)  

---

## 🛠 Home Manager

User-specific configuration lives in `hadichokr-home.nix`:

- **Zsh setup**
  - Aliases (`rebuild`, `update`, `update-home`, `update-all`)  
  - `fastfetch` runs on shell start  
- **Flatpak integration**
  - Automatic weekly updates  
  - Installed apps: Whatsie, OBS Studio, Zeal, SuperTux Party  
- **Plasma**
  - Dark Breeze look & feel  
  - Konqi wallpaper with blur  
  - F12 → Spectacle screenshot shortcut  
  - Start menu icon replaced with Nix snowflake  

---

## 🔄 Usage

Rebuild the system:

```sh
sudo nixos-rebuild switch
```

Rebuild and upgrade system:

```sh
sudo nixos-rebuild switch --upgrade
```

Update only Home Manager:

```sh
home-manager -f /etc/nixos/hadichokr-home.nix switch
```

Update everything:

```sh
sudo nixos-rebuild switch --upgrade && home-manager -f /etc/nixos/hadichokr-home.nix switch
```

---

## 📌 System Info

- **NixOS version**: `25.11` (state version)  
- **Home Manager stateVersion**: `25.05`  
- **Primary user**: `hadichokr`  

---

## 📜 License

Feel free to reuse snippets of this config — but double-check paths and usernames.  

---

✨ Powered by **NixOS**, **Home Manager**, and a touch of Konqi magic 🐉

