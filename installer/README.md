# Goudunix Installer

Goudunix is a ready-to-use NixOS system based on the Cinnamon desktop.
It borrows some of the hardening work from
[Bureautix](https://github.com/cloud-gouv/bureautix-example) and
[Securix](https://github.com/cloud-gouv/securix/) to ship a hardened
NixOS install out of the box.

The result is 100% NixOS - this is just an installer that lays down a
preconfigured NixOS system via a graphical Calamares wizard.

Goudunix is a personal project, nothing more.

## What makes this installer different from the stock NixOS one?

- **Live environment**: Cinnamon (instead of GNOME/Plasma), with every
  common video driver bundled so the installer renders on arbitrary
  hardware.
- **Goudunix modules baked in**: the full `goudunix/modules/` tree ships
  inside the ISO and is laid down on `/mnt/etc/nixos/modules/` at install
  time.
- **`goudupackages` page**: a Calamares QML view with six tabs (Internet,
  Productivity, GFX & Multimedia, Virtualization & containers, Development,
  IT / automation). Mutually-exclusive groups are radio buttons;
  free-choice groups are checkboxes.
- **GPU autodetection**: `lspci` decides between `nvidia` / `amd` / `intel`
  during install - no prompt.
- **LUKS encryption**: the "Encrypt system" checkbox is exposed in
  Calamares. Uses LUKS1 so GRUB can boot BIOS installs (LUKS2 argon2id
  is unsupported by GRUB 2.12).
- **Hostname input**: Calamares' hostname widget is forced visible
  (upstream hides it on NixOS), so every install can name itself.


## Build

Run from the repo root (where `flake.nix` lives):

```bash
nix --extra-experimental-features 'nix-command flakes' build .#iso
ls -lh result/iso/
```

If your user's Nix already has flakes enabled (via `~/.config/nix/nix.conf`
or `/etc/nix/nix.conf` with `experimental-features = nix-command flakes`),
the flag can be dropped:

```bash
nix build .#iso
```

The flag is only needed on the *builder's* Nix - the installed system
enables flakes in its own `configuration.nix`.

First build ~20 min (lots of Mint/Cinnamon deps). Subsequent builds are
incremental - under 2 min if only a module changed.



## Known limitations

- **Hybrid-GPU laptops** (Intel iGPU + NVIDIA dGPU, Optimus): `lspci`
  detects both, NVIDIA wins by default. Edit
  `/etc/nixos/modules/install-choices.nix` post-install for `nvidiaPrime`
  or similar setups.
- **Installing in a VM to clone onto physical hardware**: the GPU
  detected is the VM's (Bochs/virtio), not the target. Edit
  `install-choices.nix` after cloning.
- **No Goudunix logo yet**: the ISO reuses the upstream NixOS snowflake.
  Drop a logo in `installer/calamares/branding/goudunix/` and update
  `productIcon` / `productLogo` in `branding.desc` to point at it.
- **QML -> GlobalStorage binding**: the `goudupackages` view uses
  `Global.insert(...)` (from `import io.calamares.core 1.0`). If
  Calamares' QML API shifts between releases, only the `onLeave` handler
  at the bottom of `goudupackages.qml` needs patching.


## Download

Latest build: <https://www.be-root.com/downloads/goudunix/goudunix-installer-latest.iso>
