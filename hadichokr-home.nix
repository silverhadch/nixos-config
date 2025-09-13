{ pkgs, ... }:

let
  nix-flatpak   = builtins.fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  home.username = "hadichokr";
  home.homeDirectory = "/home/hadichokr";
  home.stateVersion = "25.05";

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

  # Cleanup after Home Manager
  services.home-manager.autoExpire.enable = true;
  services.home-manager.autoExpire.frequency = "hourly";
  services.home-manager.autoExpire.timestamp = "-3 days";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs.konsole = {
    enable = true;

    # Optional: set the default profile to the one we define
    defaultProfile = "Linux";

    # Define custom profiles
    profiles = {
      Linux = {
        name = "Linux";
        colorScheme = "Linux";      # Use the 'Linux' color scheme
        extraConfig = {
          Keyboard = {
            KeyBindings = "linux";  # Wrapped in the correct section
          };
        };
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "hadichokr@icloud.com";
    userName = "Hadi Chokr";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ll = "ls -lh --color=auto";
      la = "ls -A";
      l  = "ls -CF";

      rebuild     = "sudo nixos-rebuild switch";
      update      = "sudo nixos-rebuild switch --upgrade";
      update-home = "home-manager -f /etc/nixos/hadichokr-home.nix switch";
      update-all  = "sudo nixos-rebuild switch --upgrade && home-manager -f /etc/nixos/hadichokr-home.nix switch";

      # Alias home-manager to always use your config
      home-manager = "home-manager -f /etc/nixos/hadichokr-home.nix";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gd = "git diff";

      vi = "nvim";
      h  = "history";

      cleanup = ''
        echo "Cleaning old Nix generations, keeping last 5..."
        sudo nix-collect-garbage -d
        sudo nix-env --delete-generations old
        sudo nix-env --delete-generations +5
        echo "Cleanup done!"
      '';
    };

    oh-my-zsh = {
      enable = true;
      theme  = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        "z"
        "autojump"
        "extract"
        "docker"
        "kubectl"
        "npm"
        "golang"
        "pip"
        "tmux"
        "history-substring-search"
      ];
    };

    initContent = ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      # Load Nix-installed plugins
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      # Useful environment vars
      export EDITOR=nvim
      export VISUAL=nvim
      export PATH=$HOME/.local/bin:$PATH

      # Enable autojump if installed
      [[ -s ${pkgs.autojump}/share/autojump/autojump.zsh ]] && source ${pkgs.autojump}/share/autojump/autojump.zsh

      # Fast system info
      echo ""
      fastfetch

      # Improve history search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };

  programs.home-manager.enable = true;

  imports = [
    (import "${plasma-manager}/modules")
    "${nix-flatpak}/modules/home-manager.nix"
  ];

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
      enable = true;
      onCalendar = "weekly";
    };
  };

  programs.plasma = {
    enable = true;
    input.keyboard.layouts = [ { layout = "de"; } ];
    kwin.effects.translucency.enable = true;
    kwin.effects.wobblyWindows.enable = true;
    kwin.effects.windowOpenClose.animation = "glide";
    powerdevil.AC.whenLaptopLidClosed = "doNothing";
    spectacle.shortcuts.launch = "F12";

    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/FlyingKonqui/contents/images/1920x1080.png";
      wallpaperBackground.blur = true;
    };

    kwin.virtualDesktops = { number = 2; rows = 2; };
  };

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

