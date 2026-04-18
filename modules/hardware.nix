# Static hardware bits - Bluetooth + removable-media automount.
#
# GPU drivers, VM guest/host, and container runtimes are NOT declared here.
# They live in ./install-choices.nix, which is written by the Goudunix
# installer based on autodetection (GPU) and user selections (VM, containers).
# On manual installs, hand-edit install-choices.nix.

{ config, lib, pkgs, ... }:

{
  # ──────────────────────────────────────────────
  # Bluetooth
  # ──────────────────────────────────────────────
  hardware.bluetooth.enable = true;

  # ──────────────────────────────────────────────
  # USB / Removable media automount
  # ──────────────────────────────────────────────
  # udisks2: D-Bus service used by Nemo for mounting USB drives, SD cards, etc.
  services.udisks2.enable = true;
}
