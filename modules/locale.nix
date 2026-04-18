# Locale, keyboard, timezone.
#
# Values here are *defaults* (lib.mkDefault). At install time, the Calamares
# nixos job writes install-generated.nix using `lib.mkForce` with whatever
# the user picked in the Location / Keyboard steps, which wins over anything
# set here. So these defaults only matter if someone skips those steps or
# edits the installed system by hand later.
#
# French is a convenient default for Goudunix, not a claim about the
# installed system's actual locale.

{ config, lib, pkgs, ... }:

{
  i18n.defaultLocale = lib.mkDefault "fr_FR.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = lib.mkDefault "fr";

  time.timeZone = lib.mkDefault "Europe/Paris";
}
