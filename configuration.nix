# NixOS configuration entry point.
# Help: configuration.nix(5), https://search.nixos.org/options, `nixos-help`

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/printing.nix
    ./modules/shell.nix
    ./modules/users.nix
    ./modules/packages.nix
    ./modules/dconf.nix
    ./modules/default-apps.nix
    ./modules/overlays.nix
    ./modules/hardening.nix
    ./modules/wallpaper.nix
    ./modules/install-choices.nix   # written by the installer (GPU, VM, optional pkgs)
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
