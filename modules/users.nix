# Users.
#
# The interactive user account is created at install time by Calamares
# (see installer/calamares/modules/nixos/main.py → render_install_generated).
# That same code also adds the user to the `docker` / `vboxusers` groups
# when the corresponding choice is made on the goudupackages page, so
# nothing is hardcoded here.
#
# Use this file to declare extra service accounts, SSH-only users, or
# shared group policies.

{ config, lib, pkgs, ... }:

{
  # No static users declared. Add your own below if needed, e.g.:
  #
  # users.users.svc-backup = {
  #   isSystemUser = true;
  #   group = "svc-backup";
  #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  # };
  # users.groups.svc-backup = {};
}
