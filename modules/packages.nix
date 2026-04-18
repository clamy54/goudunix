# Baseline packages. Calamares picks go into install-choices.nix - don't
# duplicate them here, they'd become force-installed.

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Base tools
    vim
    util-linux
    git
    wget
    fastfetch

    # Terminal
    tilix

    # Graphics / Scanning / Photos
    simple-scan
    drawing
    pix

    # X-Apps (Mint/Cinnamon native)
    xed
    xviewer
    xreader
    bulky
    sticky-notes

    # GNOME utilities
    gnome-calculator
    gnome-calendar      # syncs with Cinnamon calendar applet via EDS
    gnome-system-monitor
    gnome-screenshot
    gnome-power-manager
    gnome-font-viewer
    gucharmap
    seahorse
    gparted

    # Cinnamon ecosystem
    cinnamon-translations
    nemo                # already pulled by Cinnamon, explicit for clarity

    # Nemo extensions
    nemo-fileroller     # "Extract here" / "Compress" in right-click menu
    nemo-python

    # Archive manager
    file-roller

    # Thumbnailers (video/image previews in Nemo)
    ffmpegthumbnailer

    # NetworkManager applet (systray)
    networkmanagerapplet

    # XDG utilities
    xdg-user-dirs
    xdg-utils

    # System / Configuration
    system-config-printer
    pavucontrol
    blueberry
    onboard
    orca
    polkit_gnome

    # GStreamer codecs
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-good

    # Java Runtime
    jdk21

    # Cinnamon / Mint theming
    mint-themes
    mint-y-icons
    mint-x-icons
    mint-cursor-themes
    bibata-cursors
    adwaita-icon-theme
    hicolor-icon-theme
    xapp

    # NixOS branding (nix-snowflake icons used by the menu applet)
    nixos-icons

    # Wallpapers
    nixos-artwork.wallpapers.dracula
    nixos-artwork.wallpapers.mosaic-blue
    nixos-artwork.wallpapers.simple-dark-gray

    # Sound theme
    sound-theme-freedesktop

    # Samba / CIFS client
    samba
    cifs-utils

    # LUKS userspace (luksAddKey, reencrypt, ...).
    cryptsetup
  ];
}
