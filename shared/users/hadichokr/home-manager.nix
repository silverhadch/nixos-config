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

    # docker comes from the system module, the zsh plugins from programs.zsh.
    packages = with pkgs; [
      fastfetch
      kubectl
      tmux
    ];
  };

  # ---------------------------------------------------------------------------
  # Autojump
  # ---------------------------------------------------------------------------
  programs.autojump.enable = true;

  # ---------------------------------------------------------------------------
  # Fastfetch
  # ---------------------------------------------------------------------------
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo/nixos_logo_2.webp".source = ./fastfetch/logo/nixos_logo_2.webp;

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

    remotes = {
      "flathub" = "https://flathub.org/repo/flathub.flatpakrepo";
      "webexweb" = "https://silverhadch.github.io/io.github.silverhadch.WebexWeb/index.flatpakrepo";
    };

    packages = [
      "flathub:app/com.jetbrains.IntelliJ-IDEA-Community//stable"
      "flathub:app/com.obsproject.Studio//stable"
      "flathub:app/org.kde.neochat//stable"
      "flathub:app/org.texstudio.TeXstudio//stable"
      "flathub:app/org.zealdocs.Zeal//stable"
      "flathub:app/net.codelogistics.clicker//stable"
      "flathub:app/com.ktechpit.whatsie//stable"
      "flathub:app/party.supertux.supertuxparty//stable"
      "flathub:app/app.eduroam.geteduroam//stable"
      "webexweb:app/io.github.silverhadch.WebexWeb//master"
    ];

    overrides = {
      "global" = {
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

    onCalendar = "daily";
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
      font = {
        name = "Hack";
        size = 11;
      };
      extraConfig.Keyboard.KeyBindings = "linux";
    };
  };

  # ---------------------------------------------------------------------------
  # Plasma (module injected by flake)
  # ---------------------------------------------------------------------------
  programs.plasma = {
    enable = true;

    configFile.kdeglobals.General.accentColorFromWallpaper = true;

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
      lookAndFeel = "org.kde.oxygen";
      colorScheme = "OxygenDark";

      wallpaper = "${pkgs.kdePackages.oxygen}/share/wallpapers/Horos/";

      wallpaperBackground.blur = true;
    };
  };

  # ---------------------------------------------------------------------------
  # Zed
  # ---------------------------------------------------------------------------
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" ];

    userSettings = {
      auto_update = false;

      lsp = {
        rust-analyzer = {
          binary = { path_lookup = true; };
        };
      };

      load_direnv = "shell_hook";

      agent = {
        default_model = {
          provider = "anthropic";
          model = "claude-sonnet-4-7";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Zsh
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    # Only one-liners live here; everything longer is a function in initContent
    # (aliases cannot take arguments).
    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gp = "git push";
      gs = "git status";

      h  = "history";
      l  = "ls -CF";
      la = "ls -A";
      ll = "ls -lh --color=auto";

      ds              = "devshell";
      dev-toolbox     = "distrobox enter dev-toolbox";
      kontainer-shell = "nix develop /etc/nixos#kontainer";
      list-hosts      = "ls /etc/nixos/hosts";
    };

    oh-my-zsh = {
      enable = true;
      theme  = "robbyrussell";

      # No "autojump"/"z" here: jumping is handled by programs.autojump.
      plugins = [
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
      ];
    };

    initContent = ''
      ZSH_DISABLE_COMPFIX=true

      export EDITOR=nvim
      export VISUAL=nvim
      export PATH="$HOME/.local/bin:$PATH"

      # Oxygen widget style for native Qt apps, dark GTK theme for GTK apps
      export QT_STYLE_OVERRIDE=oxygen
      export GTK_THEME=Adwaita:dark

      # devshell <name> / devshell list
      source /etc/nixos/shells/devshell.sh

      # ----------------------------------------------------------------- NixOS
      get-current-host() {
        hostnamectl hostname
      }

      rebuild() {
        run0 nixos-rebuild switch --flake "/etc/nixos#$(get-current-host)"
      }

      rebuild-host() {
        if [ $# -ne 1 ]; then
          echo "usage: rebuild-host <hostname>" >&2
          return 1
        fi
        run0 nixos-rebuild switch --flake "/etc/nixos#$1"
      }

      flake-update() {
        (cd /etc/nixos && nix flake update)
      }

      flake-check() {
        (cd /etc/nixos && nix flake check)
      }

      update() {
        (
          set -e
          cd /etc/nixos
          nix flake update
          run0 nixos-rebuild switch --flake "/etc/nixos#$(get-current-host)"
          git add .
          git commit -m "Update inputs on $(date '+%Y-%m-%d %H:%M')"
          git push
        )
      }

      cleanup() {
        echo "Cleaning old Nix generations..."
        run0 nix-collect-garbage -d
        run0 nix-env --delete-generations old
        run0 nix-env --delete-generations +5
        run0 nix-store --optimise
      }

      update-hardware-host() {
        (
          set -e
          host="$(get-current-host)"
          tmpdir="$(mktemp -d)"

          echo "→ Generating hardware config"
          run0 nixos-generate-config --dir "$tmpdir"

          echo "→ Updating hardware configuration for host: $host"
          cd /etc/nixos

          rm -f "$tmpdir/configuration.nix"
          mv "$tmpdir/hardware-configuration.nix" \
            "hosts/$host/hardware-configuration.nix"
          rmdir "$tmpdir"

          git add "hosts/$host/hardware-configuration.nix"
          git commit -m "nixos($host): update hardware configuration" || true
        )
      }

      # --------------------------------------------------------- git forensics
      what-changes() {
        echo 'What changes a lot?'
        git log --format=format: --name-only --since='1 year ago' \
          | rg -v 'po$|json$|desktop$' | sort | uniq -c | sort -nr | head -20
      }

      what-breaks() {
        echo 'What breaks a lot?'
        git log -i -E --grep='fix|bug|broke|bad|wrong|incorrect|problem' \
          --name-only --format= | sort | uniq -c | sort -nr | head -20
      }

      emergencies() {
        echo 'And what were the emergencies?'
        git log --oneline --since='1 year ago' \
          | grep -iE 'revert|hotfix|emergency|urgent|rollback'
      }

      momentum() {
        echo "What's the project's momentum over the past 5 years?"
        git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c | tail -n 60
      }

      maintainers-recently() {
        echo "Who's been driving this project in the past year?"
        git shortlog -sn --no-merges --since='1 year ago' \
          | rg -v 'l10n daemon script' | head -n 30
      }

      maintainers-alltime() {
        echo 'And what about for all time?'
        git shortlog -sn --no-merges | rg -v 'l10n daemon script' | head -n 30
      }

      repo-analysis() {
        for _fn in what-changes what-breaks emergencies \
                   momentum maintainers-recently maintainers-alltime; do
          "$_fn"
          echo
        done
      }

      clear
      fastfetch
    '';
  };
}
