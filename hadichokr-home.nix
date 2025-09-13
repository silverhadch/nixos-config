{ pkgs, ... }:

let
  nix-flatpak   = builtins.fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz";
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    plasma-manager
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
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
      ll          = "ls -l";
      rebuild     = "sudo nixos-rebuild switch";
      update      = "sudo nixos-rebuild switch --upgrade";
      update-home = "home-manager switch";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" ];
    };

    initContent = ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      echo ""
      fastfetch
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
    spectacle.shortcuts.launch = "<F12>";

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

