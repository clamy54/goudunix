# Ships the Goudunix wallpaper at a stable, system-wide path.
# Used by LightDM (modules/desktop.nix), Cinnamon dconf (modules/dconf.nix),
# and the installer's live env (installer/cinnamon-live.nix).

{ config, lib, pkgs, ... }:

{
  environment.etc."goudunix/wallpaper.png".source = ./wallpaper.png;
}
