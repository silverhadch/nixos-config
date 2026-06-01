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
  # Oxygen Dark color scheme (from KDE Store p/2066753, inlined declaratively)
  # Placed here so plasma-manager can reference it by name.
  # ---------------------------------------------------------------------------
  xdg.dataFile."color-schemes/OxygenDark.colors".text = ''
    [ColorEffects:Disabled]
    Color=56,56,56
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=112,111,110
    ColorAmount=-0.9
    ColorEffect=1
    ContrastAmount=0.25
    ContrastEffect=2
    Enable=true
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=37,40,44
    BackgroundNormal=32,36,40
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=146,76,157
    ForegroundInactive=130,130,132
    ForegroundLink=88,172,255
    ForegroundNegative=191,3,3
    ForegroundNeutral=176,128,0
    ForegroundNormal=210,210,210
    ForegroundPositive=0,110,40
    ForegroundVisited=150,111,232

    [Colors:Selection]
    BackgroundAlternate=62,138,204
    BackgroundNormal=67,172,232
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=108,36,119
    ForegroundInactive=199,226,248
    ForegroundLink=0,49,110
    ForegroundNegative=156,14,14
    ForegroundNeutral=255,221,0
    ForegroundNormal=255,255,255
    ForegroundPositive=128,255,128
    ForegroundVisited=69,40,134

    [Colors:Tooltip]
    BackgroundAlternate=40,44,50
    BackgroundNormal=24,21,19
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=255,128,224
    ForegroundInactive=130,130,132
    ForegroundLink=88,172,255
    ForegroundNegative=191,3,3
    ForegroundNeutral=176,128,0
    ForegroundNormal=231,253,255
    ForegroundPositive=0,110,40
    ForegroundVisited=150,111,232

    [Colors:View]
    BackgroundAlternate=27,30,35
    BackgroundNormal=22,26,30
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=146,76,157
    ForegroundInactive=130,130,132
    ForegroundLink=88,172,255
    ForegroundNegative=191,3,3
    ForegroundNeutral=176,128,0
    ForegroundNormal=210,210,210
    ForegroundPositive=0,110,40
    ForegroundVisited=150,111,232

    [Colors:Window]
    BackgroundAlternate=35,38,42
    BackgroundNormal=30,34,38
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=146,76,157
    ForegroundInactive=130,130,132
    ForegroundLink=88,172,255
    ForegroundNegative=191,3,3
    ForegroundNeutral=176,128,0
    ForegroundNormal=210,210,210
    ForegroundPositive=0,110,40
    ForegroundVisited=150,111,232

    [Colors:Complementary]
    BackgroundAlternate=40,44,50
    BackgroundNormal=24,21,19
    DecorationFocus=58,167,221
    DecorationHover=110,214,255
    ForegroundActive=255,128,224
    ForegroundInactive=130,130,132
    ForegroundLink=88,172,255
    ForegroundNegative=191,3,3
    ForegroundNeutral=176,128,0
    ForegroundNormal=231,253,255
    ForegroundPositive=0,110,40
    ForegroundVisited=150,111,232

    [General]
    ColorScheme=OxygenDark
    Name=Oxygen Dark
    shadeSortColumn=true

    [KDE]
    contrast=7

    [WM]
    activeBackground=48,174,232
    activeForeground=255,255,255
    inactiveBackground=35,38,42
    inactiveForeground=130,130,132
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
    };

    packages = [
      "flathub:app/com.jetbrains.IntelliJ-IDEA-Community//stable"
      "flathub:app/com.obsproject.Studio//stable"
      "flathub:app/org.texstudio.TeXstudio//stable"
      "flathub:app/org.zealdocs.Zeal//stable"
      "flathub:app/net.codelogistics.clicker//stable"
      "flathub:app/com.ktechpit.whatsie//stable"
      "flathub:app/party.supertux.supertuxparty//stable"
      "flathub:app/app.eduroam.geteduroam//stable"
    ];

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
      lookAndFeel = "org.kde.oxygen.desktop";
      colorScheme  = "OxygenDark";

      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Elarun/";

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
      run0 nixos-rebuild switch --flake /etc/nixos#$(get-current-host)
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

      # Use Oxygen widget style for native Qt apps; dark GTK theme for GTK apps
      export QT_STYLE_OVERRIDE=oxygen
      export GTK_THEME=Adwaita:dark

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
