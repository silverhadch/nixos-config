{ config, pkgs, lib, ... }:

let
  # Home Manager fetch
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  # ---------------------------------------------------------------------------
  # Imports
  # ---------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
    ./users.nix
  ];

  # ---------------------------------------------------------------------------
  # Nixpkgs overlays
  # ---------------------------------------------------------------------------
  nixpkgs.overlays = [
    (self: super: {
      bottles = super.bottles.override { removeWarningPopup = true; };

      webex = super.webex.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.makeWrapper ];

        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/opt/Webex/bin/CiscoCollabHost \
            --set WAYLAND_DISPLAY "" \
            --set XDG_SESSION_TYPE x11 \
            --set QT_QPA_PLATFORM xcb \
            --set GDK_BACKEND x11 \
            --set NIXOS_OZONE_WL 0
        '';
      });
    })
  ];


  programs.nix-ld.enable = true;

  # ---------------------------------------------------------------------------
  # Bootloader
  # ---------------------------------------------------------------------------
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 5;

  # ---------------------------------------------------------------------------
  # Kernel
  # ---------------------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "rd.systemd.show_status=auto"
    "udev.log_priority=3"
  ];

  # ---------------------------------------------------------------------------
  # Plymouth & boot tweaks
  # ---------------------------------------------------------------------------
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  # ---------------------------------------------------------------------------
  # Swap
  # ---------------------------------------------------------------------------
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16*1024;
      randomEncryption.enable = true;
    }
  ];

  # ---------------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------------
  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];


  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # --------------------------------------------------------------------------- 
  # Podman & Containers
  # ---------------------------------------------------------------------------
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  # ---------------------------------------------------------------------------
  # Locale & time
  # ---------------------------------------------------------------------------
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };
  time.timeZone = "Europe/Berlin";

  # ---------------------------------------------------------------------------
  # Console / X11 keyboard
  # ---------------------------------------------------------------------------
  console.keyMap = "de";
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # ---------------------------------------------------------------------------
  # Display manager & desktop environment
  # ---------------------------------------------------------------------------
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  hardware.graphics.enable = true;

  # ---------------------------------------------------------------------------
  # Printing
  # ---------------------------------------------------------------------------
  services.printing.enable = true;

  # ---------------------------------------------------------------------------
  # Sound
  # ---------------------------------------------------------------------------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # Flatpak
  # ---------------------------------------------------------------------------
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = [ "gtk" "kde" ];
  };

  # ---------------------------------------------------------------------------
  # AppImage
  # ---------------------------------------------------------------------------
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # ---------------------------------------------------------------------------
  # Firefox
  # ---------------------------------------------------------------------------
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
    wrapperConfig = {
      pipewireSupport = true;
    };
  };
  programs.firefox.nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];

  # ---------------------------------------------------------------------------
  # Allow unfree packages
  # ---------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # Nix / system optimizations
  # ---------------------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "hourly";
    options = "--delete-older-than 5d";
  };
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # ---------------------------------------------------------------------------
  # Auto-upgrades
  # ---------------------------------------------------------------------------
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # ---------------------------------------------------------------------------
  # Shell & Fonts
  # ---------------------------------------------------------------------------
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # ---------------------------------------------------------------------------
  # Virtualization
  # ---------------------------------------------------------------------------
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
  systemd.services.waydroid-container.enable = true;

  # ---------------------------------------------------------------------------
  # Steam
  # ---------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    btop
    bottles
    curl
    discord
    distrobox
    firefoxpwa
    flatpak
    geteduroam
    gimp
    git
    github-desktop
    htop
    kdePackages.kcalc
    kdePackages.kdevelop
    kdePackages.partitionmanager
    kdePackages.xdg-desktop-portal-kde
    libreoffice-qt-fresh
    localsend
    megasync
    nixos-bgrt-plymouth
    openconnect
    qbittorrent-enhanced
    spotify
    superTux
    superTuxKart
    thunderbird-bin
    toolbox
    vim
    vlc
    webex
    wget
    xdg-desktop-portal-gtk
    home-manager

    # -------------------------------------------------------------------------
    # C / C++ / Go / Wayland / KDE Dev Packages
    # -------------------------------------------------------------------------
    clang-tools
    cmakeWithGui
    devbox
    gcc
    gnumake
    go
    gopls
    go-md2man
    libgcc
    meson
    shadow
    podman
    vscode
    xdg-utils
    wayland-utils
    kdePackages.kde-dev-utils
    kdePackages.kdev-php
    kdePackages.kdev-python
    kdePackages.kde-dev-scripts

    # -------------------------------------------------------------------------
    # Fun / CLI toys
    # -------------------------------------------------------------------------
    cowsay
    fortune
    sl
    ponysay
    cmatrix
    toilet
    figlet
    rig
    nyancat


    # -------------------------------------------------------------------------
    # VsCode Extensions
    # -------------------------------------------------------------------------
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        dracula-theme.theme-dracula
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.makefile-tools
        yzhang.markdown-all-in-one
      ];
    })
  ];

  # ---------------------------------------------------------------------------
  # System version
  # ---------------------------------------------------------------------------
  system.stateVersion = "25.11";
}

