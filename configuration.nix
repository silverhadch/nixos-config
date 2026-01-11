{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  # ---------------------------------------------------------------------------
  # Imports
  # ---------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    (import "${home-manager}/nixos")
  ];

  # ---------------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------------
  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "boot.shell_on_fail"
      "quiet"
      "rd.systemd.show_status=auto"
      "splash"
      "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };

      timeout = 0;
    };

    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Console / X11
  # ---------------------------------------------------------------------------
  console.keyMap = "de";

  services.xserver = {
    enable = true;

    xkb = {
      layout = "de";
      variant = "";
    };
  };

  # ---------------------------------------------------------------------------
  # Desktop
  # ---------------------------------------------------------------------------
  hardware.graphics.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ---------------------------------------------------------------------------
  # Environment
  # ---------------------------------------------------------------------------
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      # Core
      btop
      btrfs-progs
      curl
      git
      htop
      neovim
      vim
      wget

      # Desktop / Apps
      bottles
      discord
      firefoxpwa
      flatpak
      gimp
      github-desktop
      libreoffice-qt-fresh
      localsend
      megasync
      nixos-bgrt-plymouth
      ocrmypdf
      qbittorrent-enhanced
      spotify
      thunderbird-bin
      vlc
      webex

      # KDE
      kdePackages.kcalc
      kdePackages.kdevelop
      kdePackages.kmines
      kdePackages.partitionmanager
      kdePackages.xdg-desktop-portal-kde

      # Containers / VM
      distrobox
      podman
      toolbox

      # Dev
      clang-tools
      cmakeWithGui
      devbox
      gcc
      gnumake
      go
      go-md2man
      gopls
      libgcc
      meson
      msedit
      shadow
      texlive.combined.scheme-small
      wayland-utils
      xdg-utils

      # KDE Dev
      kdePackages.kde-dev-scripts
      kdePackages.kde-dev-utils
      kdePackages.kdev-php
      kdePackages.kdev-python

      # Fun
      cmatrix
      cowsay
      figlet
      fortune
      nyancat
      ponysay
      rig
      sl
      toilet

      # VSCode and Extensions
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          dracula-theme.theme-dracula
          formulahendry.code-runner
          llvm-vs-code-extensions.lldb-dap
          llvm-vs-code-extensions.vscode-clangd
          ms-azuretools.vscode-docker
          ms-python.python
          ms-vscode.makefile-tools
          ms-vscode-remote.remote-ssh
          yzhang.markdown-all-in-one
        ];
      })

      home-manager

      # vi compatibility shim for shits and giggles
      (pkgs.writeShellScriptBin "vi" ''
        exec vim -u NONE -C "$@"
      '')

      # sudo to run0 shim
      (pkgs.writeShellScriptBin "sudo" ''
        exec run0 "$@"
      '')

      # optional muscle-memory shims
      (pkgs.writeShellScriptBin "doas" ''
        exec run0 "$@"
      '')

      (pkgs.writeShellScriptBin "pkexec" ''
        exec run0 "$@"
      '')
    ];
  };

  # ---------------------------------------------------------------------------
  # Flatpak / Portals
  # ---------------------------------------------------------------------------
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    config.common.default = [ "gtk" "kde" ];

    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };

  # ---------------------------------------------------------------------------
  # Fonts
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };

      Policy.AutoEnable = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Locale / Time
  # ---------------------------------------------------------------------------
  i18n = {
    defaultLocale = "de_DE.UTF-8";

    extraLocaleSettings = {
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
  };

  time.timeZone = "Europe/Berlin";

  # ---------------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------------
  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;

      plugins = with pkgs; [
        networkmanager-openconnect
      ];

      ensureProfiles.profiles.fuVpn = {
        connection = {
          id = "FU VPN";
          type = "vpn";
          autoconnect = false;
        };

        ipv4.method = "auto";
        ipv6.method = "disabled";

        vpn = {
          gateway = "vpn.fu-berlin.de";
          protocol = "anyconnect";
          service-type = "org.freedesktop.NetworkManager.openconnect";

          reported-os = "ios";
          reported-version = "5.1.6.103";
          useragent = "AnyConnect";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------------
  nix = {
    gc = {
      automatic = true;
      dates = "hourly";
      options = "--delete-older-than 5d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (self: super: {
        bottles = super.bottles.override {
          removeWarningPopup = true;
        };

        webex = super.webex.overrideAttrs (old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or []) ++ [ super.makeWrapper ];

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
  };

  # ---------------------------------------------------------------------------
  # Avahi
  # ---------------------------------------------------------------------------
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # Printing
  # ---------------------------------------------------------------------------
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-browsed
      cups-filters
    ];
  };

  # ---------------------------------------------------------------------------
  # Audio
  # ---------------------------------------------------------------------------
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # Programs
  # ---------------------------------------------------------------------------
  programs = {
    appimage = {
      enable = true;
      binfmt = true;
    };

    firefox = {
      enable = true;

      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      wrapperConfig.pipewireSupport = true;
    };

    nix-ld.enable = true;
    steam.enable = true;
    virt-manager.enable = true;
    zsh.enable = true;
  };

  programs.firefox.nativeMessagingHosts.packages = [
    pkgs.firefoxpwa
  ];

  # ---------------------------------------------------------------------------
  # Swap
  # ---------------------------------------------------------------------------
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
      randomEncryption.enable = true;
    }
  ];

  # ---------------------------------------------------------------------------
  # Users / Shell
  # ---------------------------------------------------------------------------
  users.defaultUserShell = pkgs.zsh;

  # kill sudo, embrace run0
  security.sudo.enable = false;

  # ---------------------------------------------------------------------------
  # Virtualisation
  # ---------------------------------------------------------------------------
  virtualisation = {
    containers.enable = true;

    libvirtd.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    spiceUSBRedirection.enable = true;

    waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };

  systemd.services.waydroid-container.enable = true;

  # ---------------------------------------------------------------------------
  # System
  # ---------------------------------------------------------------------------
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
    };

    stateVersion = "25.11";
  };
}
