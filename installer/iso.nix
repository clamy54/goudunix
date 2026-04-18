# Installer ISO specifics:
#  - bakes modules/*.nix into /etc/goudunix/modules in the live system
#  - bakes the install-choices template into /etc/goudunix/templates/
#  - swaps upstream calamares-nixos-extensions for the Goudunix fork
#  - sets ISO naming

{ config, lib, pkgs, ... }:

let
  goudunixVersion = "0.1.0";
in
{
  image.baseName    = lib.mkForce "goudunix-installer-${goudunixVersion}";
  isoImage.volumeID = lib.mkForce
    "GOUDUNIX_${builtins.replaceStrings ["."] ["_"] goudunixVersion}";

  # The Calamares nixos job copies this into /mnt/etc/nixos/modules/ at
  # install time (see installer/calamares/modules/nixos/main.py).
  environment.etc."goudunix/modules" = {
    source = ../modules;
  };

  environment.etc."goudunix/templates/install-choices.nix.in" = {
    source = ./templates/install-choices.nix.in;
  };

  # Use `prev.calamares-nixos-extensions` as the input to avoid feeding the
  # fork into itself (infinite recursion).
  nixpkgs.overlays = [
    (final: prev: {
      calamares-nixos-extensions = final.callPackage ./calamares {
        calamares-nixos-extensions = prev.calamares-nixos-extensions;
      };
    })
  ];
}
