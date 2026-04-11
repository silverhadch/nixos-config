{ config, pkgs, USERNAME, NAME, ... }:

{
  # ---------------------------------------------------------------------------
  # Home basics
  # ---------------------------------------------------------------------------
  home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = "/home/${USERNAME}";
    stateVersion = "26.05";
    username = USERNAME;

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
  # DOSBox
  # ---------------------------------------------------------------------------
  xdg.configFile."dosbox/dosbox-staging.conf".text = ''
    [dos]
    keyboardlayout=de
  '';

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
  # Flatpak (managed by declarative-flatpak module)
  # ---------------------------------------------------------------------------
  services.flatpak = {
    enable = true;

    # Remotes to add (usually just flathub)
    remotes = {
      "flathub" = "https://flathub.org/repo/flathub.flatpakrepo";
    };

    # List of packages to install. Format: "remote:type/ID//branch"
    # You can verify branch names with `flatpak remote-info flathub <app-id>`
    packages = [
      "flathub:app/com.obsproject.Studio//stable"
      "flathub:app/org.texstudio.TeXstudio//stable"
      "flathub:app/org.zealdocs.Zeal//stable"
      "flathub:app/net.codelogistics.clicker//stable"
      "flathub:app/com.ktechpit.whatsie//stable"
      "flathub:app/party.supertux.supertuxparty//stable"
      "flathub:app/app.eduroam.geteduroam//stable"
    ];

    # Overrides (global and per‑application)
    overrides = {
      "global" = {
        Context = {
          sockets = [ "wayland" "x11" "fallback-x11" ];
        };
        Environment = {
          GTK_THEME    = "Adwaita:dark";
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
        };
      };
      "com.ktechpit.whatsie" = {
        Context = {
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
    };

    # Automatic update schedule (systemd timer)
    onCalendar = "daily";   # checks for updates every day
  };

  # ---------------------------------------------------------------------------
  # Git
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "${USERNAME}@icloud.com";
        name  = NAME;
      };
      sendemail = {
        smtpserver = "smtp.mail.me.com";
        smtpuser = "${USERNAME}@icloud.com";
        smtpencryption = "tls";
        smtpserverport = 587;
      };
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
        "/etc/nixos/images/nixos-wallpaper-catppuccin-mocha.svg";

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

      ds = "devshell";

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

      # Source devshell function
      source /etc/nixos/shells/devshell.sh

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

      alias what-changes="echo 'What changes a lot?' && git log --format=format: --name-only --since='1 year ago' | rg -v 'po$|json$|desktop$' | sort | uniq -c | sort -nr | head -20"
      alias what-breaks="echo 'What breaks a lot?' && git log -i -E --grep='fix|bug|broke|bad|wrong|incorrect|problem' --name-only --format="" | sort | uniq -c | sort -nr | head -20"
      alias emergencies="echo 'And what were the emergencies?' && git log --oneline --since='1 year ago' | grep -iE 'revert|hotfix|emergency|urgent|rollback'"
      alias momentum="echo \"What's the project's momentum over the past 5 years?\" && git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c | tail -n 60"
      alias maintainers-recently="echo \"Who's been driving this project in the past year?\" && git shortlog -sn --no-merges --since='1 year ago' | rg -v 'l10n daemon script' | head -n 30"
      alias maintainers-alltime="echo 'And what about for all time?' && git shortlog -sn --no-merges | rg -v 'l10n daemon script' | head -n 30"
      function repo-analysis {
          what-changes
          echo
          what-breaks
          echo
          emergencies
          echo
          momentum
          echo
          maintainers-recently
          echo
          maintainers-alltime
      }

      clear
      fastfetch
    '';
  };
}
