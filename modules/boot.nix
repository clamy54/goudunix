# Plymouth, initrd, filesystems. Bootloader lives in install-choices.nix
# (the installer is EFI/BIOS-aware).

{ config, lib, pkgs, ... }:

{
  # "spinner" reads /etc/plymouth/logo.png; "bgrt" pulls from firmware
  # BGRT and renders blank on VMs.
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };
  boot.initrd.systemd.enable = true; # clean Plymouth -> LightDM handoff

  boot.kernelParams = [ "quiet" "splash" ];

  boot.supportedFilesystems = [ "nfs" ];

  # Example NFS mount:
  # fileSystems."/mnt/nfs/share" = {
  #   device = "192.168.1.100:/export/share";
  #   fsType = "nfs";
  #   options = [
  #     "nfsvers=4.2"
  #     "x-systemd.automount"
  #     "noauto"
  #     "x-systemd.idle-timeout=600"
  #   ];
  # };
}
