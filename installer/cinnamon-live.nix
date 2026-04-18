# Cinnamon live environment for the installer ISO.
# Layered on top of installation-cd-graphical-calamares.nix (flake.nix).

{ config, lib, pkgs, ... }:

let
  installDesktopFile = pkgs.writeText "install-system.desktop" ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Install System
    GenericName=System Installer
    Comment=Install Goudunix to your hard drive
    Exec=calamares
    Icon=calamares
    Terminal=false
    Categories=System;Settings;
    StartupNotify=true
  '';
in
{
  imports = [
    # Same wallpaper path as the installed system.
    ../modules/wallpaper.nix
  ];

  isoImage.edition = lib.mkDefault "cinnamon";

  services.xserver.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
      extraConfig = ''
        background=/etc/goudunix/wallpaper.png
        background-color=#000000
        draw-user-backgrounds=false
      '';
    };
  };

  # Cinnamon wallpaper for the live (autologin) session.
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/cinnamon/desktop/background" = {
            picture-uri = "file:///etc/goudunix/wallpaper.png";
            picture-options = "zoom";
            primary-color = "#000000";
          };
        };
      }
    ];
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Manual relaunch icon (autostart already fires it once).
  systemd.tmpfiles.rules = [
    "d /home/nixos/Desktop 0755 nixos users -"
    "C+ /home/nixos/Desktop/install-system.desktop 0755 nixos users - ${installDesktopFile}"
  ];

  # Default French; Calamares' keyboard step can override.
  services.xserver.xkb = {
    layout = lib.mkDefault "fr";
    variant = lib.mkDefault "";
  };
  console.keyMap = lib.mkDefault "fr";

  # Calamares rendering fix on Wayland (harmless on X11).
  environment.variables.QT_QPA_PLATFORM =
    "$([[ $XDG_SESSION_TYPE = \"wayland\" ]] && echo \"wayland\")";

  # Common GPU drivers; nvidia proprietary is added post-install.
  services.xserver.videoDrivers = [
    "amdgpu"
    "nouveau"
    "modesetting"
    "fbdev"
    "vmware"
    "virtio"
    "qxl"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # nixos-install needs flakes to build configs that declare them.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # calamares-nixos / autostart / partition-manager come from upstream.
  environment.systemPackages = with pkgs; [
    mint-themes
    mint-y-icons
    bibata-cursors

    gparted
    firefox
    nemo
    gnome-terminal

    cryptsetup
  ];
}
