# GPU + VM + optional packages. The installer rewrites this from a
# template at install time. The defaults below just keep a VMware VM
# booting out of a fresh clone.

{ config, lib, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  virtualisation.vmware.guest = {
    enable = true;
    headless = false;
  };
}
