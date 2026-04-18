# X11, LightDM + Slick greeter, Cinnamon, XDG portals, GNOME integration bits,
# fonts, French XDG user-dirs.

{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;

  # Keyboard layout for X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # LightDM with Slick Greeter (Linux Mint default)
  services.xserver.displayManager.lightdm = {
    enable = true;

    greeters.slick = {
      enable = true;
      font.name = "Ubuntu 14";

      theme = {
        name = "Mint-Y-Aqua";
        package = pkgs.mint-themes;
      };

      iconTheme = {
        name = "Mint-Y-Sand";
        package = pkgs.mint-y-icons;
      };

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };

      extraConfig = ''
        greeter-hide-users=true
        activate-numlock=true
        background=/etc/goudunix/wallpaper.png
        background-color=#000000
        show-hostname=true
        draw-user-backgrounds=false
        draw-grid=false
        show-a11y=true
        show-keyboard=false
        show-clock=true
        clock-format=%a, %b %d  %H:%M
      '';
    };
  };

  # Cinnamon Desktop Environment
  services.xserver.desktopManager.cinnamon.enable = true;

  # Drop gnome-terminal from the Cinnamon default app set. Goudunix ships
  # Tilix as the system terminal (see org/cinnamon/desktop/applications/
  # terminal override in dconf.nix) - gnome-terminal would otherwise get
  # pinned on the Cinnamon taskbar by default, duplicating the UX.
  environment.cinnamon.excludePackages = [ pkgs.gnome-terminal ];

  # Polkit - authentication agent, required by many desktop actions (and realmd)
  security.polkit.enable = true;

  # evolution-data-server: required for gnome-calendar ↔ Cinnamon calendar applet sync
  services.gnome.evolution-data-server.enable = true;

  # GNOME Keyring - stores Wi-Fi passwords, browser credentials, SSH keys
  services.gnome.gnome-keyring.enable = true;

  # XDG Desktop Portals - native file dialogs for Firefox, Flatpak apps, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # XDG user directories (~/Documents, ~/Téléchargements, etc. in French)
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=Bureau
    DOWNLOAD=Téléchargements
    TEMPLATES=Modèles
    PUBLICSHARE=Public
    DOCUMENTS=Documents
    MUSIC=Musique
    PICTURES=Images
    VIDEOS=Vidéos
  '';

  # ──────────────────────────────────────────────
  # Fonts
  # ──────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Linux Mint default fonts
      ubuntu-classic

      # Noto family (broad Unicode coverage)
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # Liberation (metric-compatible with Arial, Times, Courier)
      liberation_ttf

      # DejaVu
      dejavu_fonts

      # FreeFont
      freefont_ttf

      # FiraCode Nerd Font (for Tilix default font)
      nerd-fonts.fira-code

      # Caladea & Carlito (metric-compatible with Cambria & Calibri)
      caladea
      carlito
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Ubuntu" "Noto Sans" "DejaVu Sans" ];
        serif = [ "Noto Serif" "DejaVu Serif" "Liberation Serif" ];
        monospace = [ "FiraCode Nerd Font" "DejaVu Sans Mono" "Noto Sans Mono" ];
      };
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      antialias = true;
    };
  };
}
