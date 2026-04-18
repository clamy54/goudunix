# Network stack: NetworkManager (via systemd-resolved), SSH, firewall,
# mDNS / WS-Discovery for LAN visibility, CIFS client via GVFS.

{ config, lib, pkgs, ... }:

{
  networking.hostName = "nixos";

  # NetworkManager delegates DNS to systemd-resolved so the resolver hardening
  # (LLMNR / mDNS disabled) in hardening.nix actually takes effect.
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  # ──────────────────────────────────────────────
  # DNS resolver (systemd-resolved)
  # ──────────────────────────────────────────────
  services.resolved = {
    enable = true;
    llmnr = "false";         # disable LLMNR (spoofing vector)
    extraConfig = ''
      MulticastDNS=false
    '';
  };

  # ──────────────────────────────────────────────
  # SSH Server
  # ──────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";           # "yes", "no", or "prohibit-password" (key-only)
      PasswordAuthentication = true;     # set to false to force key-based auth only
    };
  };

  # ──────────────────────────────────────────────
  # Firewall (NixOS native, nftables-based)
  # ──────────────────────────────────────────────
  # Fully declarative - openFirewall on services works automatically.
  networking.firewall.enable = true;

  # ──────────────────────────────────────────────
  # SMB/CIFS - client only (no Samba server daemon)
  # ──────────────────────────────────────────────
  # cifs-utils + gvfs-smb = mount shares from Nemo or CLI (mount -t cifs / smb://).
  # GVFS for Nemo network browsing (smb://, ftp://, etc.)
  services.gvfs.enable = true;

  # Avahi for mDNS/DNS-SD service discovery on the LAN
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;   # opens 5353/udp
  };

  # WS-Discovery - make this host visible in the "network neighborhood"
  # of Windows 10+ clients.
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;   # opens 3702/tcp+udp
  };
}
