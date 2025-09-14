{ pkgs, ... }:

let
  # External Home Manager modules
  nix-flatpak    = builtins.fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  ## ── Home user basics ───────────────────────────────────────────────
  home.username      = "hadichokr";
  home.homeDirectory = "/home/hadichokr";
  home.stateVersion  = "25.05";  # Update this only when upgrading HM

  ## ── Packages installed in home environment ─────────────────────────
  home.packages = with pkgs; [
    plasma-manager
    zsh-autosuggestions
    zsh-syntax-highlighting
    autojump
    tmux
    docker
    kubectl
    fastfetch
  ];

  ## ── Housekeeping: auto-expire HM generations ───────────────────────
  services.home-manager.autoExpire = {
    enable     = true;
    frequency  = "hourly";
    timestamp  = "-3 days";  # Delete generations older than 3 days
  };

  ## ── Development toolbox container (Debian Unstable) ─────────────────────────
  programs.distrobox = {
    enable = true;

    # Global distrobox settings
    settings = {
      container_manager = "podman"; # Use podman instead of docker
      container_name_default = "toolbox-dev";
      container_generate_entry = 1;
      container_always_pull = 1; # Always pull latest image
    };

    containers.toolbox-dev = {
      image = "docker.io/library/debian:unstable";   # Debian unstable base
      entry = true;

      # Extra packages to bootstrap the dev environment
      additional_packages = [
        # Build tools
        "cmake" "meson" "ninja-build" "gcc" "g++" "make" "pkg-config"

        # Parser tools
        "bison" "flex"

        # XML / Docbook
        "libxml2-dev" "libxslt1-dev"
        "docbook-dtds" "docbook-xsl" "itstool"

        # Python tooling
        "python3" "python3-pip" "python3-setuptools"

        # Subid headers & libs
        "libsubid-dev"

        # Shell completions
        "bash-completion" "fish" "zsh"

        # Security / crypto
        "openssl" "libssl-dev" "p11-kit" "podman" "skopeo"

        # Linting & testing
        "shellcheck" "bats" "codespell"

        # Go tooling
        "golang" "golang-godoc"

        # Nice-to-have
        "fastfetch"
      ];
    };
  };


  ## ── Virt-manager settings ──────────────────────────────────────────
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris        = [ "qemu:///system" ];
    };
  };

  ## ── Konsole configuration ──────────────────────────────────────────
  programs.konsole = {
    enable         = true;
    defaultProfile = "Linux";

    profiles.Linux = {
      name        = "Linux";
      colorScheme = "Linux";   # Matches default Linux scheme
      extraConfig.Keyboard.KeyBindings = "linux";
    };
  };

  ## ── Git config ─────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    userName  = "Hadi Chokr";
    userEmail = "hadichokr@icloud.com";
  };

  ## ── Zsh config ─────────────────────────────────────────────────────
  programs.zsh = {
    enable           = true;
    enableCompletion = true;

    # Custom aliases
    shellAliases = {
      # ls variations
      ll = "ls -lh --color=auto";
      la = "ls -A";
      l  = "ls -CF";

      # NixOS rebuild / upgrade
      rebuild     = "sudo nixos-rebuild switch";
      update      = "sudo nixos-rebuild switch --upgrade";
      update-home = "home-manager -f /etc/nixos/hadichokr-home.nix switch";
      update-all  = "sudo nixos-rebuild switch --upgrade && home-manager -f /etc/nixos/hadichokr-home.nix switch";

      # Always use your config
      home-manager = "home-manager -f /etc/nixos/hadichokr-home.nix";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gd = "git diff";

      # Distrobox shortcuts
      assemble-toolbox-dev = "distrobox assemble create --replace --file ~/.config/distrobox/containers.ini";
      toolbox-dev = "distrobox enter toolbox-dev";

      # Misc
      vi = "nvim";
      h  = "history";

      # Cleanup old generations
      cleanup = ''
        echo "Cleaning old Nix generations, keeping last 5..."
        sudo nix-collect-garbage -d
        sudo nix-env --delete-generations old
        sudo nix-env --delete-generations +5
        echo "Cleanup done!"
      '';
    };

    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      plugins = [
        "git" "sudo" "z" "autojump" "extract"
        "docker" "kubectl" "npm" "golang" "pip"
        "tmux" "history-substring-search"
      ];
    };

    # Zsh init script
    initContent = ''
      ZSH_DISABLE_COMPFIX=true 
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      # Load Nix-installed plugins
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      # Environment variables
      export EDITOR=nvim
      export VISUAL=nvim
      export PATH=$HOME/.local/bin:$PATH

      # Autojump
      [[ -s ${pkgs.autojump}/share/autojump/autojump.zsh ]] && source ${pkgs.autojump}/share/autojump/autojump.zsh
      
      # Fast system info
      clear
      echo ""
      fastfetch

      # History search with arrow keys
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

    '';
  };

  ## ── Home Manager self-management ───────────────────────────────────
  programs.home-manager.enable = true;

  ## ── Import external modules ────────────────────────────────────────
  imports = [
    (import "${plasma-manager}/modules")
    "${nix-flatpak}/modules/home-manager.nix"
  ];

  ## ── Flatpak integration ────────────────────────────────────────────
  services.flatpak = {
    enable = true;
    packages = [
      "com.ktechpit.whatsie"
      "com.obsproject.Studio"
      "org.kde.neochat"
      "org.zealdocs.Zeal"
      "party.supertux.supertuxparty"
    ];
    update.auto = {
      enable     = true;
      onCalendar = "daily";
    };
  };

  ## ── Plasma desktop settings ────────────────────────────────────────
  programs.plasma = {
    enable = true;

    # Keyboard
    input.keyboard.layouts = [ { layout = "de"; } ];

    # Effects
    kwin.effects = {
      translucency.enable       = true;
      wobblyWindows.enable      = true;
      windowOpenClose.animation = "fade";
    };

    # Power
    powerdevil.AC.whenLaptopLidClosed = "doNothing";

    # Shortcuts
    spectacle.shortcuts.launch = "F12";

    # Workspace
    workspace = {
      clickItemTo       = "open";
      lookAndFeel       = "org.kde.breezedark.desktop";
      wallpaper         = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/FlyingKonqui/contents/images/1920x1080.png";
      wallpaperBackground.blur = true;
    };

    kwin.virtualDesktops = {
      number = 2;
      rows   = 2;
    };
  };

  ## ── Custom activation hooks ────────────────────────────────────────
  home.activation.set-plasma-startmenu-icon = ''
    echo "Setting Plasma Application Launcher icon…"
    section='[Containments][2][Applets][3][Configuration][General]'
    config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    cp "$config" "$config.home-manager-backup"
    grep -q "^$section" "$config" || echo "$section" >> "$config"
    grep -q "^icon=" "$config" && \
      sed -i "/^$section/,/^\[/ s/^icon=.*/icon=nix-snowflake/" "$config" || \
      sed -i "/^$section/a icon=nix-snowflake" "$config"
  '';
}
