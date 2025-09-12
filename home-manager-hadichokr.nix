{ config, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # External modules
  # ---------------------------------------------------------------------------
  nix-flatpak = builtins.fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  # ---------------------------------------------------------------------------
  # Normal user
  # ---------------------------------------------------------------------------
  users.users.hadichokr = {
    isNormalUser = true;
    description = "Hadi Chokr";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
      fastfetch
      kdePackages.kate
      neovim
      pkgs.oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };

  # ---------------------------------------------------------------------------
  # User groups
  # ---------------------------------------------------------------------------
  users.groups.libvirtd.members = [ "hadichokr" ];

  # ---------------------------------------------------------------------------
  # Home Manager configuration
  # ---------------------------------------------------------------------------
  home-manager.users.hadichokr = { pkgs, ... }: {
    home.stateVersion = "25.05";

    # -------------------------------------------------------------------------
    # User packages
    # -------------------------------------------------------------------------
    home.packages = with pkgs; [
      plasma-manager
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];

    # -------------------------------------------------------------------------
    # DConf settings
    # -------------------------------------------------------------------------
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    # -------------------------------------------------------------------------
    # Git
    # -------------------------------------------------------------------------
    programs.git = {
      enable = true;
      userEmail = "hadichokr@icloud.com";
      userName = "Hadi Chokr";
    };

    # -------------------------------------------------------------------------
    # Zsh + Oh-My-Zsh
    # -------------------------------------------------------------------------
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      # Aliases
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };

      # Oh-My-Zsh configuration
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "sudo" ];
      };

      # Extra plugin initialization
      initContent = ''
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
        source $ZSH/oh-my-zsh.sh

        # Load zsh plugins
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        echo ""
        fastfetch
      '';
    };

    # -------------------------------------------------------------------------
    # Enable Home Manager itself
    # -------------------------------------------------------------------------
    programs.home-manager.enable = true;

    # -------------------------------------------------------------------------
    # Additional modules
    # -------------------------------------------------------------------------
    imports = [
      (import "${plasma-manager}/modules")
      "${nix-flatpak}/modules/home-manager.nix"
    ];

    # -------------------------------------------------------------------------
    # Flatpak packages
    # -------------------------------------------------------------------------
    services.flatpak = {
      enable = true;
      packages = [
        "com.ktechpit.whatsie"
        "com.obsproject.Studio"
        "org.zealdocs.Zeal"
        "party.supertux.supertuxparty"
      ];
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };

    # -------------------------------------------------------------------------
    # Plasma workspace configuration
    # -------------------------------------------------------------------------
    programs.plasma = {
      enable = true;

      # Keyboard layouts
      input.keyboard.layouts = [ { layout = "de"; } ];

      # KWin effects
      kwin.effects.translucency.enable = true;
      kwin.effects.wobblyWindows.enable = true;
      kwin.effects.windowOpenClose.animation = "glide";

      # Power settings
      powerdevil.AC.whenLaptopLidClosed = "doNothing";

      # Shortcuts
      spectacle.shortcuts.launch = "<F12>";

      # Workspace appearance
      workspace = {
        clickItemTo = "open";
        lookAndFeel = "org.kde.breezedark.desktop";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/FlyingKonqui/contents/images/1920x1080.png";
        wallpaperBackground.blur = true;
      };

      # Virtual desktops
      kwin.virtualDesktops = { number = 2; rows = 2; };
    };

    # -------------------------------------------------------------------------
    # Activate Plasma start menu icon
    # -------------------------------------------------------------------------
    home.activation.set-plasma-startmenu-icon = ''
      echo "Setting Plasma Application Launcher icon…"
      section='[Containments][2][Applets][3][Configuration][General]'
      config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

      # Backup original config
      cp "$config" "$config.home-manager-backup"

      # Add section if missing
      grep -q "^$section" "$config" || echo "$section" >> "$config"

      # Add or update icon
      grep -q "^icon=" "$config" && \
        sed -i "/^$section/,/^\[/ s/^icon=.*/icon=nix-snowflake/" "$config" || \
        sed -i "/^$section/a icon=nix-snowflake" "$config"
    '';
  };

  # ---------------------------------------------------------------------------
  # Global Home Manager options
  # ---------------------------------------------------------------------------
  home-manager.backupFileExtension = "backup";
}

