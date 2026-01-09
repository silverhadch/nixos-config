{ config, pkgs, ... }:

let
  nix-flatpak = builtins.fetchTarball
    "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";

  plasma-manager = builtins.fetchTarball
    "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  # ---------------------------------------------------------------------------
  # Home basics
  # ---------------------------------------------------------------------------
  home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = "/home/hadichokr";
    stateVersion = "26.05";
    username = "hadichokr";

    packages = with pkgs; [
      autojump
      docker
      fastfetch
      kubectl
      plasma-manager
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };

  # ---------------------------------------------------------------------------
  # Dconf
  # ---------------------------------------------------------------------------
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris        = [ "qemu:///system" ];
    };
  };

  # ---------------------------------------------------------------------------
  # Distrobox
  # ---------------------------------------------------------------------------
  programs.distrobox = {
    enable = true;

    settings = {
      container_always_pull      = 1;
      container_generate_entry   = 1;
      container_manager          = "podman";
      container_name_default     = "toolbox-dev";
    };

    containers.toolbox-dev = {
      entry = true;
      image = "docker.io/library/debian:unstable";

      additional_packages = [
        # Build
        "bison" "cmake" "flex" "gcc" "g++" "make"
        "meson" "ninja-build" "pkg-config"

        # Docs / XML
        "docbook-xsl" "itstool" "libxml2-dev" "libxslt1-dev"

        # Go
        "golang" "go-md2man"

        # Python
        "python3" "python3-pip" "python3-setuptools"

        # System
        "fastfetch" "libsubid-dev" "systemd-dev"
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Flatpak
  # ---------------------------------------------------------------------------
  services.flatpak = {
    enable = true;

    packages = [
      "app.eduroam.geteduroam"
      "com.ktechpit.whatsie"
      "com.obsproject.Studio"
      "it.mijorus.gearlever"
      "net.codelogistics.clicker"
      "org.kde.neochat"
      "org.zealdocs.Zeal"
      "party.supertux.supertuxparty"
    ];

    overrides = {
      global = {
        Context.sockets = [ "wayland" "!x11" "!fallback-x11" ];

        Environment = {
          GTK_THEME    = "Adwaita:dark";
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
        };
      };

      "com.ktechpit.whatsie".Context = {
        filesystems = [
          "home:rw"
          "/run/current-system/sw/bin:ro"
        ];

        sockets = [
          "gpg-agent"
          "pcsc"
        ];
      };
    };

    update.auto = {
      enable     = true;
      onCalendar = "daily";
    };
  };

  # ---------------------------------------------------------------------------
  # Git
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;

    settings.user = {
      email = "hadichokr@icloud.com";
      name  = "Hadi Chokr";
    };
  };

  # ---------------------------------------------------------------------------
  # Home Manager self-management
  # ---------------------------------------------------------------------------
  programs.home-manager.enable = true;

  services.home-manager.autoExpire = {
    enable    = true;
    frequency = "hourly";
    timestamp = "-3 days";
  };

  # ---------------------------------------------------------------------------
  # Konsole
  # ---------------------------------------------------------------------------
  programs.konsole = {
    enable = true;

    defaultProfile = "Linux";

    profiles.Linux = {
      name = "Linux";
      colorScheme = "Linux";
      extraConfig.Keyboard.KeyBindings = "linux";
    };
  };

  # ---------------------------------------------------------------------------
  # Plasma
  # ---------------------------------------------------------------------------
  programs.plasma = {
    enable = true;

    input.keyboard.layouts = [
      { layout = "de"; }
    ];

    kwin = {
      effects = {
        translucency.enable       = true;
        wobblyWindows.enable      = true;
        windowOpenClose.animation = "fade";
      };

      virtualDesktops = {
        number = 2;
        rows   = 2;
      };
    };

    powerdevil.AC.whenLaptopLidClosed = "doNothing";

    spectacle.shortcuts.launch = "F12";

    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";

      wallpaper =
        "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/FlyingKonqui/";

      wallpaperBackground.blur = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Zsh
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    dotDir = "${config.xdg.configHome}/zsh";

    shellAliases = {
      cleanup = ''
        echo "Cleaning old Nix generations..."
        sudo nix-collect-garbage -d
        sudo nix-env --delete-generations old
        sudo nix-env --delete-generations +5
      '';

      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gp = "git push";
      gs = "git status";

      h  = "history";
      l  = "ls -CF";
      la = "ls -A";
      ll = "ls -lh --color=auto";

      rebuild     = "sudo nixos-rebuild switch";
      update      = "sudo nixos-rebuild switch --upgrade";
      update-home = "home-manager -f /etc/nixos/hadichokr-home.nix switch";
      update-all  = "sudo nixos-rebuild switch --upgrade && home-manager -f /etc/nixos/hadichokr-home.nix switch";

      toolbox-dev = "distrobox enter toolbox-dev";
      vi = "nvim";
    };

    oh-my-zsh = {
      enable = true;
      theme  = "robbyrussell";

      plugins = [
        "autojump"
        "docker"
        "extract"
        "git"
        "golang"
        "history-substring-search"
        "kubectl"
        "npm"
        "pip"
        "sudo"
        "tmux"
        "z"
      ];
    };

    initContent = ''
      ZSH_DISABLE_COMPFIX=true
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      [[ -s ${pkgs.autojump}/share/autojump/autojump.zsh ]] && source ${pkgs.autojump}/share/autojump/autojump.zsh

      export EDITOR=nvim
      export VISUAL=nvim
      export PATH=$HOME/.local/bin:$PATH

      clear
      fastfetch
    '';
  };

  # ---------------------------------------------------------------------------
  # Imports
  # ---------------------------------------------------------------------------
  imports = [
    (import "${plasma-manager}/modules")
    "${nix-flatpak}/modules/home-manager.nix"
  ];
}
