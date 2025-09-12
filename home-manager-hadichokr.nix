{ config, pkgs, ... }:

let
  # Fetch nix-flatpak
  nix-flatpak = builtins.fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";

  # Fetch Plasma Manager as a standalone module
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  # The normal user
  users.users.hadichokr = {
    isNormalUser = true;
    description = "Hadi Chokr";
    extraGroups = [ "networkmanager" "wheel" "libvirtd"];
    packages = with pkgs; [
      kdePackages.kate
      pkgs.oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
      neovim
      fastfetch
    ];
  };

  users.groups.libvirtd.members = ["hadichokr"];

  # Home Manager configuration for the user
  home-manager.users.hadichokr = { pkgs, ... }: {
    home.stateVersion = "25.05";

    # Packages installed in user environment
    home.packages = with pkgs; [
      zsh-autosuggestions
      zsh-syntax-highlighting
      plasma-manager
    ];

    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    # Git config
    programs.git = {
      enable = true;
      userName = "Hadi Chokr";
      userEmail = "hadichokr@icloud.com";
    };

    # Zsh + Oh-My-Zsh
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "sudo"
        ];
      };

      # Load extra plugins manually
      initContent = ''
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
        source $ZSH/oh-my-zsh.sh

        # zsh plugins
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        echo ""
        fastfetch
      '';
    };

    # Enable Home Manager
    programs.home-manager.enable = true;

    # Enable Plasma Manager
    imports = [
      (import "${plasma-manager}/modules")
      "${nix-flatpak}/modules/home-manager.nix"
    ];

    # Configure nix-flatpak
    services.flatpak = {
      enable = true;
      packages = [
        "org.zealdocs.Zeal"
	"com.obsproject.Studio"
	"party.supertux.supertuxparty"
	"com.ktechpit.whatsie"
      ];
    };

    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };

    # Plasma 4 / KDE 4 compatible settings
    programs.plasma = {
      enable = true;

      # Workspace settings
      workspace = {
        clickItemTo = "open";
        lookAndFeel = "org.kde.breezedark.desktop";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/FlyingKonqui/contents/images/1920x1080.png";
	wallpaperBackground.blur = true;
      };

      # Virtual desktops
      kwin.virtualDesktops = {
        number = 2;
        rows = 2;
      };

      # KWin effects
      kwin.effects.wobblyWindows.enable = true;
      kwin.effects.translucency.enable = true;
      kwin.effects.windowOpenClose.animation = "glide";

      # Power settings
      powerdevil.AC.whenLaptopLidClosed = "doNothing";

      # Keyboard layouts (list format)
      input.keyboard.layouts = [
        {
          layout = "de";
        }
      ];

      # Shortcuts
      spectacle.shortcuts.launch = "<F12>";
    };

    # Activation script to set the Plasma start menu icon
    home.activation.set-plasma-startmenu-icon = ''
      echo "Setting Plasma Application Launcher icon…"

      section='[Containments][2][Applets][3][Configuration][General]'
      config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

      # Backup first
      cp "$config" "$config.home-manager-backup"

      # Add section if missing
      grep -q "^$section" "$config" || echo "$section" >> "$config"

      # Add icon= if missing, or replace if present
      grep -q "^icon=" "$config" && \
        sed -i "/^$section/,/^\[/ s/^icon=.*/icon=nix-snowflake/" "$config" || \
        sed -i "/^$section/a icon=nix-snowflake" "$config"
    '';
  };

  # Global Home Manager option
  home-manager.backupFileExtension = "backup";
}

