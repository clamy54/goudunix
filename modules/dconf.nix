# System-wide Cinnamon / GTK / Nemo / Tilix defaults for every user.

{ config, lib, pkgs, ... }:

let
  # Shared UUID so the Tilix profile below is actually selected.
  tilixProfileUuid = "2b7c4080-0ddd-46c5-8f23-563fd3ba789d";
in
{
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          # Cinnamon Shell Theme
          "org/cinnamon/theme" = {
            name = "Mint-Y-Dark-Aqua";
          };

          # GTK / Interface
          "org/cinnamon/desktop/interface" = {
            gtk-theme = "Mint-Y-Aqua";
            icon-theme = "Mint-Y-Sand";
            cursor-theme = "Bibata-Modern-Classic";
            cursor-size = lib.gvariant.mkUint32 24;
            font-name = "Ubuntu 10";
            font-antialiasing = "rgba";
            font-hinting = "slight";
            gtk-overlay-scrollbars = true;
          };

          # Window Manager
          "org/cinnamon/desktop/wm/preferences" = {
            theme = "Mint-Y-Aqua";
            titlebar-font = "Ubuntu Medium 10";
            button-layout = ":minimize,maximize,close";
            num-workspaces = lib.gvariant.mkInt32 4;
          };

          # GNOME-level fallback (some GTK apps read this)
          "org/gnome/desktop/interface" = {
            document-font-name = "Sans 10";
            monospace-font-name = "FiraCode Nerd Font 10";
            cursor-theme = "Bibata-Modern-Classic";
            cursor-size = lib.gvariant.mkUint32 24;
          };

          # Nemo (file manager)
          "org/nemo/desktop" = {
            font = "Ubuntu 10";
            desktop-layout = "true";
          };

          "org/nemo/preferences" = {
            default-folder-viewer = "icon-view";
            show-hidden-files = false;
            show-image-thumbnails = "always";
          };

          # Trailing :N pins the applet instance-id (must match default-apps.nix).
          "org/cinnamon" = {
            panels-height = [ "1:40" ];
            next-applet-id = lib.gvariant.mkInt32 16;
            enabled-applets = [
              "panel1:left:0:menu@cinnamon.org:1"
              "panel1:left:1:show-desktop@cinnamon.org:2"
              "panel1:left:2:grouped-window-list@cinnamon.org:3"
              "panel1:right:0:systray@cinnamon.org:4"
              "panel1:right:1:xapp-status@cinnamon.org:5"
              "panel1:right:2:keyboard@cinnamon.org:6"
              "panel1:right:3:notifications@cinnamon.org:7"
              "panel1:right:4:printers@cinnamon.org:8"
              "panel1:right:5:removable-drives@cinnamon.org:9"
              "panel1:right:6:favorites@cinnamon.org:10"
              "panel1:right:7:network@cinnamon.org:11"
              "panel1:right:8:sound@cinnamon.org:12"
              "panel1:right:9:power@cinnamon.org:13"
              "panel1:right:10:calendar@cinnamon.org:14"
              "panel1:right:11:user@cinnamon.org:15"
            ];
            # Mint-menu favorites (taskbar pins live in default-apps.nix).
            favorite-apps = [
              "nemo.desktop"
              "default-browser.desktop"
              "default-terminal.desktop"
            ];
            desktop-effects = true;
            desktop-effects-style = "traditional";
          };

          # Menu applet icon/label are in xlet-settings, see default-apps.nix.

          "org/cinnamon/desktop/applications/terminal" = {
            exec = "tilix";
            exec-arg = "-e";
          };

          # Without this Tilix picks a random UUID and ignores our profile.
          "com/gexperts/Tilix/profiles" = {
            default = tilixProfileUuid;
            list = [ tilixProfileUuid ];
          };

          # Tilix default profile: FiraCode, dark bg, white fg.
          "com/gexperts/Tilix/profiles/${tilixProfileUuid}" = {
            visible-name = "Default";
            use-system-font = false;
            font = "FiraCode Nerd Font 11";
            use-theme-colors = false;
            foreground-color = "#FFFFFF";
            background-color = "#000000";
            bold-color-same-as-fg = true;
            bold-is-bright = true;
            background-transparency-percent = lib.gvariant.mkInt32 20;
            palette = [
              "#000000" "#3F3F3F"
              "#CC0000" "#EF2929"
              "#4E9A06" "#8AE234"
              "#C4A000" "#FCE94F"
              "#3465A4" "#729FCF"
              "#75507B" "#AD7FA8"
              "#06989A" "#34E2E2"
              "#D3D7CF" "#EEEEEC"
            ];
          };

          # Wallpaper
          "org/cinnamon/desktop/background" = {
            picture-uri = "file:///etc/goudunix/wallpaper.png";
            picture-options = "zoom";
            primary-color = "#000000";
          };

          # Screensaver / lock screen
          "org/cinnamon/desktop/screensaver" = {
            lock-enabled = true;
            lock-delay = lib.gvariant.mkUint32 0;
          };

          "org/cinnamon/desktop/notifications" = {
            display-notifications = true;
          };

          "org/cinnamon/desktop/sound" = {
            event-sounds = true;
            theme-name = "freedesktop";
            login-enabled = true;
            logout-enabled = true;
          };

          # NumLock on at session start
          "org/cinnamon/desktop/peripherals/keyboard" = {
            numlock-state = "on";
          };

          # Touchpad (laptops)
          "org/cinnamon/desktop/peripherals/touchpad" = {
            tap-to-click = true;
          };

          # No USB autorun (security).
          "org/cinnamon/desktop/media-handling" = {
            autorun-never = true;
          };
        };
      }
    ];
  };
}
