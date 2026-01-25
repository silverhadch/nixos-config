{ config, pkgs, ... }:

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
      container_always_pull    = 1;
      container_generate_entry = 1;
      container_manager        = "podman";
      container_name_default   = "dev-toolbox";
    };

    containers.dev-toolbox = {
      entry = true;
      image = "docker.io/library/debian:unstable";

      additional_packages = [
        "bison" "cmake" "flex" "gcc" "g++" "make"
        "meson" "ninja-build" "pkg-config"
        "docbook-xsl" "itstool" "libxml2-dev" "libxslt1-dev"
        "golang" "go-md2man"
        "python3" "python3-pip" "python3-setuptools"
        "fastfetch" "libsubid-dev" "systemd-dev"
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Flatpak (module provided by flake)
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
      "org.texstudio.TeXstudio"
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
  # Plasma (module injected by flake)
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
        run0 nix-collect-garbage -d
        run0 nix-env --delete-generations old
        run0 nix-env --delete-generations +5
        run0 nix-store --optimise
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

      rebuild = "run0 nixos-rebuild switch --flake /etc/nixos#$(get-current-host)";
      update  = ''
      cd /etc/nixos
      nix flake update
      run0 nixos-rebuild switch --upgrade --flake /etc/nixos#$(get-current-host)
      git add .
      git commit -m "Update inputs on $(date '+%Y-%m-%d %H:%M')"
      git push
      cd -
      '';

      list-hosts   = "ls /etc/nixos/hosts";
      rebuild-host = "run0 nixos-rebuild switch --flake /etc/nixos#$1";

      dev-toolbox = "distrobox enter dev-toolbox";
      kontainer-shell = "nix develop /etc/nixos#kontainer";
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

      get-current-host() {
        hostnamectl hostname
      }

      flake-update() {
        cd /etc/nixos || return 1
        nix flake update
      }

      flake-check() {
        cd /etc/nixos || return 1
        nix flake check
      }

      update-hardware-host() {
        set -e
        local host tmpdir
        host="$(get-current-host)"
        tmpdir="$(mktemp -d)"

        echo "→ Generating hardware config"
        run0 nixos-generate-config --dir "$tmpdir"

        echo "→ Updating hardware configuration for host: $host"
        cd /etc/nixos || return 1

        rm -f "$tmpdir/configuration.nix"

        mv "$tmpdir/hardware-configuration.nix" \
          "hosts/$host/hardware-configuration.nix"

        rmdir "$tmpdir"

        git add "hosts/$host/hardware-configuration.nix"
        git commit -m "nixos($host): update hardware configuration" || true
      }

      export EDITOR=nvim
      export VISUAL=nvim
      export PATH=$HOME/.local/bin:$PATH

      clear
      fastfetch
    '';
  };
}
