{
  description = "Goudunix - installer ISO (NixOS 25.11, Cinnamon live + Calamares with goudupackages)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
          ./installer/cinnamon-live.nix
          ./installer/iso.nix
        ];
      };

      packages.${system} = {
        iso = self.nixosConfigurations.installer.config.system.build.isoImage;
        default = self.packages.${system}.iso;
      };

      apps.${system}.test = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.${system}.writeShellScript "goudunix-test-qemu" ''
          set -eu
          ISO=$(ls -1 ${self.packages.${system}.iso}/iso/*.iso | head -n1)
          DISK=''${DISK:-/tmp/goudunix-test.qcow2}
          if [ ! -f "$DISK" ]; then
            ${nixpkgs.legacyPackages.${system}.qemu}/bin/qemu-img create -f qcow2 "$DISK" 40G
          fi
          exec ${nixpkgs.legacyPackages.${system}.qemu}/bin/qemu-system-x86_64 \
            -m 4G -enable-kvm -cpu host \
            -cdrom "$ISO" \
            -drive "file=$DISK,format=qcow2" \
            -boot d
        '');
      };
    };
}
