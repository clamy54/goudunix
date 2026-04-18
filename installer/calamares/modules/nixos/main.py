#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Goudunix fork of calamares-nixos-extensions/modules/nixos/main.py.
# Drops upstream's DE picker and writes a modular Goudunix config to /mnt.

import configparser
import libcalamares
import os
import shutil
import string
import subprocess
import re
import traceback

import gettext

_ = gettext.translation(
    "calamares-python",
    localedir=libcalamares.utils.gettext_path(),
    languages=libcalamares.utils.gettext_languages(),
    fallback=True,
).gettext


GOUDUNIX_MODULES_SRC = "/etc/goudunix/modules"
TEMPLATE_PATH = "/etc/goudunix/templates/install-choices.nix.in"

# goudu.browser -> nixpkgs attr. default-apps.nix scans share/applications/
# for the real .desktop (vendors don't agree on the name).
BROWSER_PKG_ATTR = {
    "firefox":       "firefox",
    "chromium":      "chromium",
    "brave":         "brave",
    "vivaldi":       "vivaldi",
    "google-chrome": "google-chrome",
}


# Rough RHEL @development-tools equivalent. `make` is reserved (gnumake);
# source-highlight only resolves as sourceHighlight; systemtap lives under
# linuxPackages.*.
DEV_PACKAGES = [
    "autoconf", "automake", "binutils", "bison", "flex",
    "gcc", "gdb", "libtool", "gnumake", "pkgconf", "rpm", "strace",
    "asciidoc", "byacc", "diffstat", "git", "intltool", "ltrace",
    "patchutils", "pesign", "sourceHighlight", "linuxPackages.systemtap",
    "valgrind", "cmake", "expect", "perl",
]

GOUDUNIX_MODULES = [
    "boot.nix",
    "hardware.nix",
    "locale.nix",
    "networking.nix",
    "desktop.nix",
    "audio.nix",
    "printing.nix",
    "shell.nix",
    "users.nix",
    "packages.nix",
    "dconf.nix",
    "default-apps.nix",
    "overlays.nix",
    "hardening.nix",
    "wallpaper.nix",
]


def detect_gpu():
    """Return one of: 'nvidia', 'amd', 'intel', 'none'."""
    try:
        out = subprocess.check_output(["lspci", "-nn"], text=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "none"
    vga = [l for l in out.splitlines()
           if "VGA compatible controller" in l or "3D controller" in l]
    # NVIDIA first so it wins on hybrid laptops. Vendor IDs: NVIDIA=10de,
    # AMD=1002/1022, Intel=8086.
    if any("[10de:" in l for l in vga): return "nvidia"
    if any("[1002:" in l or "[1022:" in l for l in vga): return "amd"
    if any("[8086:" in l for l in vga): return "intel"
    return "none"


def nix_list(values):
    if not values:
        return "[ ]"
    return "[ " + " ".join(values) + " ]"


def nix_str_list(values):
    if not values:
        return "[ ]"
    return "[ " + " ".join('"' + s + '"' for s in values) + " ]"


def render_install_choices(gs):
    """Render install-choices.nix.in using goudu.* GS keys."""
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        tmpl = string.Template(f.read())

    gpu       = gs.value("goudu.gpu")       or "none"
    vm_guest  = gs.value("goudu.vm_guest")  or "none"
    vm_host   = gs.value("goudu.vm_host")   or "none"
    container = gs.value("goudu.container") or "none"
    browser   = gs.value("goudu.browser")   or "none"
    dev       = bool(gs.value("goudu.dev"))

    # QML arrays don't round-trip through Global.insert in 3.4; rebuild here.
    editors = []
    if gs.value("goudu.editor_vscode"):   editors.append("vscode")
    if gs.value("goudu.editor_vscodium"): editors.append("vscodium")
    it = []
    if gs.value("goudu.it_ansible"):    it.append("ansible")
    if gs.value("goudu.it_glpi_agent"): it.append("glpi-agent")

    # Used by docker / vboxusers group blocks below.
    username = gs.value("username") or "user"

    libcalamares.utils.debug(
        f"goudu choices: gpu={gpu} vm_guest={vm_guest} vm_host={vm_host} "
        f"container={container} browser={browser} editors={editors} "
        f"dev={dev} it={it} username={username}"
    )

    # GPU block
    gpu_block = ""
    if gpu == "nvidia":
        gpu_block = (
            "  hardware.graphics.enable = true;\n"
            "  services.xserver.videoDrivers = [ \"nvidia\" ];\n"
            "  hardware.nvidia = {\n"
            "    modesetting.enable = true;\n"
            "    open = false;\n"
            "    nvidiaSettings = true;\n"
            "  };\n"
        )
    elif gpu == "amd":
        gpu_block = (
            "  hardware.graphics.enable = true;\n"
            "  hardware.graphics.enable32Bit = true;\n"
            "  services.xserver.videoDrivers = [ \"amdgpu\" ];\n"
        )
    elif gpu == "intel":
        gpu_block = (
            "  hardware.graphics.enable = true;\n"
            "  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];\n"
        )

    # VM guest
    vm_guest_block = ""
    if vm_guest == "vmware":
        vm_guest_block = (
            "  virtualisation.vmware.guest = {\n"
            "    enable = true;\n"
            "    headless = false;\n"
            "  };\n"
        )
    elif vm_guest == "vbox":
        vm_guest_block = (
            "  virtualisation.virtualbox.guest = {\n"
            "    enable = true;\n"
            "    clipboard = true;\n"
            "    dragAndDrop = true;\n"
            "  };\n"
        )

    # VM host
    vm_host_block = ""
    if vm_host == "vmware":
        vm_host_block = (
            "  virtualisation.vmware.host.enable = true;\n"
            "  boot.kernelParams = [ \"transparent_hugepage=never\" ];\n"
        )
    elif vm_host == "vbox":
        # Extension Pack OFF: Oracle's PUEL blocks prebuilts, flipping this
        # forces a hours-long from-source VirtualBox build.
        vm_host_block = (
            "  virtualisation.virtualbox.host = {\n"
            "    enable = true;\n"
            "    enableExtensionPack = false;\n"
            "  };\n"
            f"  users.extraGroups.vboxusers.members = [ \"{username}\" ];\n"
        )

    # Container
    container_block = ""
    if container == "docker":
        container_block = (
            "  virtualisation.docker = {\n"
            "    enable = true;\n"
            "    enableOnBoot = true;\n"
            "  };\n"
            f"  users.extraGroups.docker.members = [ \"{username}\" ];\n"
        )
    elif container == "podman":
        container_block = (
            "  virtualisation.podman = {\n"
            "    enable = true;\n"
            "    dockerCompat = true;\n"
            "    defaultNetwork.settings.dns_enabled = true;\n"
            "  };\n"
        )

    browser_block = ""
    pkg_attr = BROWSER_PKG_ATTR.get(browser)
    if pkg_attr:
        browser_block = (
            f"  goudunix.defaultBrowserPkg = pkgs.{pkg_attr};\n"
        )

    return tmpl.safe_substitute(
        gpu_block=gpu_block,
        vm_guest_block=vm_guest_block,
        vm_host_block=vm_host_block,
        container_block=container_block,
        browser_block=browser_block,
    )


def render_install_generated(gs, fw_type, bootdev):
    """install-generated.nix: boot, host, tz, locale, kb, user."""
    # BIOS+GRUB on an encrypted /boot needs enableCryptodisk.
    partitions = gs.value("partitions") or []
    root_encrypted = any(
        p.get("mountPoint") == "/"     and p.get("fsName") in ("luks", "luks2")
        for p in partitions)
    boot_is_own_partition = any(
        p.get("mountPoint") == "/boot" for p in partitions)
    boot_encrypted = any(
        p.get("mountPoint") == "/boot" and p.get("fsName") in ("luks", "luks2")
        for p in partitions)
    needs_cryptodisk = boot_encrypted or (root_encrypted and not boot_is_own_partition)

    boot_block = ""
    if fw_type == "efi":
        boot_block = (
            "  boot.loader.systemd-boot.enable = true;\n"
            "  boot.loader.efi.canTouchEfiVariables = true;\n"
        )
    elif bootdev != "nodev":
        boot_block = (
            "  boot.loader.grub.enable = true;\n"
            f"  boot.loader.grub.device = \"{bootdev}\";\n"
            "  boot.loader.grub.useOSProber = true;\n"
        )
        if needs_cryptodisk:
            boot_block += "  boot.loader.grub.enableCryptodisk = true;\n"
    else:
        boot_block = "  boot.loader.grub.enable = false;\n"

    hostname = gs.value("hostname") or "goudunix"

    tz = ""
    if gs.value("locationRegion") and gs.value("locationZone"):
        tz = (f"  time.timeZone = lib.mkForce "
              f"\"{gs.value('locationRegion')}/{gs.value('locationZone')}\";\n")

    locale_block = ""
    if gs.value("localeConf"):
        lc = dict(gs.value("localeConf"))
        lang = lc.pop("LANG", "en_US.UTF-8/UTF-8").split("/")[0]
        locale_block = f"  i18n.defaultLocale = lib.mkForce \"{lang}\";\n"
        extra = []
        for k, v in lc.items():
            vv = v.split("/")[0]
            if vv and vv != lang:
                extra.append(f"    {k} = \"{vv}\";")
        if extra:
            locale_block += "  i18n.extraLocaleSettings = lib.mkForce {\n"
            locale_block += "\n".join(extra) + "\n"
            locale_block += "  };\n"

    kb_block = ""
    if gs.value("keyboardLayout"):
        layout = gs.value("keyboardLayout")
        variant = gs.value("keyboardVariant") or ""
        kb_block = (
            "  services.xserver.xkb = lib.mkForce {\n"
            f"    layout = \"{layout}\";\n"
            f"    variant = \"{variant}\";\n"
            "  };\n"
        )
        if gs.value("keyboardVConsoleKeymap"):
            kb_block += (
                f"  console.keyMap = lib.mkForce "
                f"\"{gs.value('keyboardVConsoleKeymap').strip()}\";\n"
            )

    user_block = ""
    if gs.value("username"):
        username = gs.value("username")
        fullname = gs.value("fullname") or username
        user_block = (
            f"  users.users.{username} = {{\n"
            "    isNormalUser = true;\n"
            f"    description = \"{fullname}\";\n"
            "    extraGroups = [ \"networkmanager\" \"wheel\" ];\n"
            "  };\n"
        )

    return (
        "# install-generated.nix - written at install time by Calamares.\n"
        "# Overrides hostname / timezone / locale / keyboard from the\n"
        "# Goudunix default modules, and declares the user + bootloader.\n"
        "{ config, lib, pkgs, ... }:\n\n"
        "{\n"
        + boot_block + "\n"
        + f"  networking.hostName = lib.mkForce \"{hostname}\";\n"
        + tz
        + locale_block
        + kb_block
        + "\n"
        + user_block
        + "}\n"
    )


def write_goudunix_entrypoint(root_mount_point, gs):
    """Overwrite /mnt/etc/nixos/configuration.nix with an entry point that
    imports every module in /mnt/etc/nixos/modules/."""
    path = os.path.join(root_mount_point, "etc/nixos/configuration.nix")
    imports = ["./hardware-configuration.nix"]
    imports += [f"./modules/{m}" for m in GOUDUNIX_MODULES]
    imports += [
        "./modules/install-choices.nix",
        "./modules/install-generated.nix",
    ]
    # Default True: NVIDIA / Brave / Chrome and other recommended pkgs are unfree.
    allow_unfree = gs.value("nixos_allow_unfree")
    if allow_unfree is None:
        allow_unfree = True
    allow_unfree_str = "true" if allow_unfree else "false"

    content = (
        "# Goudunix - entry point generated by the installer.\n"
        "# Don't edit directly; edit the modules under ./modules/.\n\n"
        "{ config, lib, pkgs, ... }:\n\n"
        "{\n"
        "  imports = [\n"
        + "\n".join(f"    {i}" for i in imports) + "\n"
        + "  ];\n\n"
        f"  nixpkgs.config.allowUnfree = {allow_unfree_str};\n"
        "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];\n"
        "  system.stateVersion = \"25.11\";\n"
        "}\n"
    )
    libcalamares.utils.host_env_process_output(
        ["cp", "/dev/stdin", path], None, content
    )


def collect_calamares_packages(gs):
    """Flat list of nixpkgs attrs picked on the goudupackages tabs, spliced
    into the installed packages.nix so everything's in one place."""
    out = []

    browser = gs.value("goudu.browser") or "none"
    if browser != "none":
        out.append(browser)
    mail = gs.value("goudu.mail_client") or "none"
    if mail != "none":
        out.append(mail)

    # joplin-desktop is the GUI; okular/kdenlive only under kdePackages.*.
    PROD_MAP = {
        "goudu.prod_libreoffice": "libreoffice-fresh",
        "goudu.prod_joplin":      "joplin-desktop",
        "goudu.prod_zim":         "zim",
        "goudu.prod_element":     "element-desktop",
        "goudu.prod_nextcloud":   "nextcloud-client",
        "goudu.prod_logseq":      "logseq",
        "goudu.prod_keepassxc":   "keepassxc",
        "goudu.prod_okular":      "kdePackages.okular",
        "goudu.prod_scribus":     "scribus",
    }
    for key, pkg in PROD_MAP.items():
        if gs.value(key):
            out.append(pkg)

    GFX_MAP = {
        "goudu.gfx_vlc":        "vlc",
        "goudu.gfx_gimp":       "gimp",
        "goudu.gfx_pinta":      "pinta",
        "goudu.gfx_audacious":  "audacious",
        "goudu.gfx_audacity":   "audacity",
        "goudu.gfx_obs_studio": "obs-studio",
        "goudu.gfx_kdenlive":   "kdePackages.kdenlive",
        "goudu.gfx_inkscape":   "inkscape",
        "goudu.gfx_krita":      "krita",
        "goudu.gfx_clementine": "clementine",
    }
    for key, pkg in GFX_MAP.items():
        if gs.value(key):
            out.append(pkg)

    # zed -> zed-editor (the `zed` attr is a different package).
    if gs.value("goudu.editor_vscode"):    out.append("vscode")
    if gs.value("goudu.editor_vscodium"):  out.append("vscodium")
    if gs.value("goudu.editor_neovim"):    out.append("neovim")
    if gs.value("goudu.editor_zed"):       out.append("zed-editor")
    if bool(gs.value("goudu.dev")):
        out += DEV_PACKAGES

    if gs.value("goudu.it_ansible"):    out.append("ansible")
    if gs.value("goudu.it_glpi_agent"): out.append("glpi-agent")

    return out


def patch_packages_nix(root_mount_point, extras):
    """Splice picked packages into modules/packages.nix so one `cat` shows
    everything installed."""
    if not extras:
        return
    path = os.path.join(root_mount_point, "etc/nixos/modules/packages.nix")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    idx = content.rfind("  ];")
    if idx == -1:
        libcalamares.utils.warning(
            "packages.nix: cannot locate systemPackages closing bracket; "
            "Calamares picks NOT spliced in")
        return
    block = (
        "\n"
        "    # Calamares-selected packages (goudupackages step).\n"
        "    # Edit freely and run `sudo nixos-rebuild switch` - this file\n"
        "    # is NOT regenerated after install.\n"
        + "".join(f"    {p}\n" for p in extras)
    )
    new_content = content[:idx] + block + content[idx:]
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)


def copy_goudunix_modules(root_mount_point):
    """Copy the modules tree. shutil (not cp) because the source is a
    read-only nix-store symlink."""
    src = os.path.realpath(GOUDUNIX_MODULES_SRC)
    dst = os.path.join(root_mount_point, "etc/nixos/modules")
    shutil.copytree(src, dst, dirs_exist_ok=True, symlinks=False)
    # Give the admin a writable tree.
    for d, _dirs, files in os.walk(dst):
        os.chmod(d, 0o755)
        for f in files:
            os.chmod(os.path.join(d, f), 0o644)


# BIOS + encrypted /boot keyfile dance (kept from upstream).
def setup_luks_keyfile(root_mount_point, gs, fw_type):
    partitions = gs.value("partitions") or []
    root_is_encrypted = False
    boot_is_encrypted = False
    boot_is_partition = False
    for part in partitions:
        if part["mountPoint"] == "/":
            root_is_encrypted = part["fsName"] in ("luks", "luks2")
        elif part["mountPoint"] == "/boot":
            boot_is_partition = True
            boot_is_encrypted = part["fsName"] in ("luks", "luks2")

    if fw_type == "efi" or not (
        (boot_is_partition and boot_is_encrypted)
        or (root_is_encrypted and not boot_is_partition)
    ):
        return  # nothing to do

    libcalamares.utils.host_env_process_output(
        ["mkdir", "-p", root_mount_point + "/boot"], None)
    libcalamares.utils.host_env_process_output(
        ["chmod", "0700", root_mount_point + "/boot"], None)
    libcalamares.utils.host_env_process_output(
        ["dd", "bs=512", "count=4", "if=/dev/random",
         "of=" + root_mount_point + "/boot/crypto_keyfile.bin",
         "iflag=fullblock"], None)
    libcalamares.utils.host_env_process_output(
        ["chmod", "600", root_mount_point + "/boot/crypto_keyfile.bin"], None)

    for part in partitions:
        if (part.get("claimed")
                and part["fsName"] in ("luks", "luks2")
                and part.get("device")):
            # luksConvertKey is LUKS2-only; LUKS1 is already pbkdf2.
            if part["fsName"] == "luks2":
                libcalamares.utils.host_env_process_output(
                    ["cryptsetup", "luksConvertKey", "--hash", "sha256",
                     "--pbkdf", "pbkdf2", part["device"]], None,
                    part["luksPassphrase"])
            libcalamares.utils.host_env_process_output(
                ["cryptsetup", "luksAddKey", "--hash", "sha256",
                 "--pbkdf", "pbkdf2", part["device"],
                 root_mount_point + "/boot/crypto_keyfile.bin"], None,
                part["luksPassphrase"])


def env_is_set(name):
    v = os.environ.get(name)
    return v is not None and v != ""


def generate_proxy_strings():
    proxy_env = []
    for name in ("http_proxy", "https_proxy", "HTTP_PROXY", "HTTPS_PROXY"):
        if env_is_set(name):
            proxy_env.append(f"{name}={os.environ.get(name)}")
    if proxy_env:
        proxy_env.insert(0, "env")
    return proxy_env


status = _("Installing Goudunix")


def pretty_name():
    return status


def pretty_status_message():
    return status


def run():
    # Calamares' generic exception popup hides the traceback; surface it.
    try:
        return _run()
    except Exception as e:
        tb = traceback.format_exc()
        libcalamares.utils.error(tb)
        return (_("Goudunix install failed"),
                f"{type(e).__name__}: {e}\n\n{tb}")


def _run():
    global status
    gs = libcalamares.globalstorage
    root_mount_point = gs.value("rootMountPoint")
    fw_type = gs.value("firmwareType")
    bootdev = "nodev" if gs.value("bootLoader") is None \
        else gs.value("bootLoader")["installPath"]

    status = _("Detecting GPU")
    libcalamares.job.setprogress(0.05)
    gs.insert("goudu.gpu", detect_gpu())

    status = _("Generating hardware configuration")
    libcalamares.job.setprogress(0.10)
    try:
        subprocess.check_output(
            ["pkexec", "nixos-generate-config", "--root", root_mount_point],
            stderr=subprocess.STDOUT,
        )
    except subprocess.CalledProcessError as e:
        msg = e.output.decode("utf8", errors="replace") if e.output else "unknown error"
        return (_("nixos-generate-config failed"), msg)

    setup_luks_keyfile(root_mount_point, gs, fw_type)

    status = _("Writing Goudunix configuration")
    libcalamares.job.setprogress(0.20)

    copy_goudunix_modules(root_mount_point)
    patch_packages_nix(root_mount_point, collect_calamares_packages(gs))

    choices = render_install_choices(gs)
    libcalamares.utils.host_env_process_output(
        ["cp", "/dev/stdin",
         os.path.join(root_mount_point,
                      "etc/nixos/modules/install-choices.nix")],
        None, choices,
    )

    generated = render_install_generated(gs, fw_type, bootdev)
    libcalamares.utils.host_env_process_output(
        ["cp", "/dev/stdin",
         os.path.join(root_mount_point,
                      "etc/nixos/modules/install-generated.nix")],
        None, generated,
    )

    write_goudunix_entrypoint(root_mount_point, gs)

    status = _("Running nixos-install (this will take a while)")
    libcalamares.job.setprogress(0.30)

    # Pass flakes explicitly in case /etc/nix/nix.conf doesn't have them.
    cmd = ["pkexec"] + generate_proxy_strings() + [
        "nixos-install",
        "--no-root-passwd",
        "--root", root_mount_point,
        "--option", "experimental-features", "nix-command flakes",
        "--option", "build-dir", "/nix/var/nix/builds",
    ]

    try:
        output = ""
        # errors="replace" so a stray non-UTF-8 byte doesn't kill the install.
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)
        while True:
            raw = proc.stdout.readline()
            if not raw:
                break
            line = raw.decode("utf-8", errors="replace")
            output += line
            libcalamares.utils.debug(f"nixos-install: {line.strip()}")
        exit_code = proc.wait()
        if exit_code != 0:
            return (_("nixos-install failed"), output)
    except Exception as e:
        return (_("nixos-install failed"),
                _("Installation failed to complete: %s") % str(e))

    libcalamares.job.setprogress(1.0)
    return None
