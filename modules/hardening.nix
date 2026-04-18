# Security hardening inspired by Securix / ANSSI.
# Sources: Securix (cloud-gouv/securix) modules/anssi/kernel-options.nix

{ config, lib, pkgs, ... }:

{
  # ── R8: Kernel boot parameters (desktop-friendly subset) ──
  boot.kernelParams = [
    "pti=on"                            # Page Table Isolation (Meltdown mitigation)
    "slab_nomerge=yes"                  # prevent slab cache merging (heap hardening)
    "spec_store_bypass_disable=seccomp" # Spectre v4 mitigation for seccomp processes
    "spectre_v2=on"                     # Spectre v2 mitigation
    "mds=full"                          # MDS mitigation (Hyper-Threading conservé)
    "page_alloc.shuffle=1"              # randomize page allocator freelists
    # "iommu=force"                     # DMA attack protection - uncomment if hardware supports it
  ];

  # ── R9: Kernel sysctl hardening ──
  boot.kernel.sysctl = {
    # Restrict dmesg to root (info leakage prevention)
    "kernel.dmesg_restrict" = 1;
    # Hide kernel symbol addresses from unprivileged users
    "kernel.kptr_restrict" = 2;
    # Maximum paranoia for perf_event (block unprivileged access)
    "kernel.perf_event_paranoid" = 3;
    # Full ASLR (Address Space Layout Randomization)
    "kernel.randomize_va_space" = 2;
    # Disable Magic SysRq key
    "kernel.sysrq" = 0;
    # Disable unprivileged BPF (prevents BPF-based attacks)
    "kernel.unprivileged_bpf_disabled" = 1;

    # ── R11: Yama LSM - restrict ptrace ──
    "kernel.yama.ptrace_scope" = 1;     # only parent can ptrace child

    # ── R12: Network stack hardening (IPv4) ──
    "net.core.bpf_jit_harden" = 2;                   # harden BPF JIT compiler
    "net.ipv4.conf.all.accept_redirects" = 0;         # ignore ICMP redirects
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;      # reject source-routed packets
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.log_martians" = 1;             # log impossible addresses
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;                # strict reverse path filtering
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.send_redirects" = 0;           # don't send ICMP redirects
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.tcp_syncookies" = 1;                    # SYN flood protection

    # IPv6 - same hardening
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # ── R14: Filesystem protections ──
    "fs.suid_dumpable" = 0;                # no core dumps for setuid binaries
    "fs.protected_fifos" = 2;              # restrict FIFO creation in sticky dirs
    "fs.protected_regular" = 2;            # restrict regular file creation in sticky dirs
    "fs.protected_symlinks" = 1;           # prevent symlink attacks in sticky dirs
    "fs.protected_hardlinks" = 1;          # prevent hardlink attacks
  };

  # ── Audit daemon (optional - uncomment if you need traceability) ──
  # security.auditd.enable = true;
  # security.audit = {
  #   enable = true;
  #   rules = [
  #     "-a exit,always -F arch=b64 -S execve"
  #   ];
  # };

  # ── Journal size limit (prevent disk exhaustion) ──
  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  # ── /tmp as tmpfs (no persistent data, mounted noexec/nosuid) ──
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "1G";  # increase if large temp files cause issues (e.g. big archives)
  };

  # ── Sudo hardening ──
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture = always
      Defaults logfile = /var/log/sudo.log
      Defaults passwd_timeout = 1
      Defaults timestamp_timeout = 5
    '';
  };

  # ── Disable unused kernel modules (attack surface reduction) ──
  boot.blacklistedKernelModules = [
    "dccp"       # rarely used transport protocol
    "sctp"       # rarely used transport protocol
    "rds"        # rarely used socket type
    "tipc"       # cluster IPC, not needed on workstations
    "n-hdlc"     # old serial protocol
    "ax25"       # amateur radio
    "netrom"     # amateur radio
    "x25"        # old WAN protocol
    "rose"       # amateur radio
    "decnet"     # old DEC protocol
    "econet"     # old Acorn protocol
    "af_802154"  # IoT radio
    "ipx"        # Novell IPX
    "appletalk"  # Apple legacy
    "psnap"      # legacy
    "p8023"      # legacy
    "cramfs"     # legacy compressed filesystem
    "freevxfs"   # legacy filesystem
    "hfs"        # legacy Apple filesystem
    "hfsplus"    # legacy Apple filesystem
    "jffs2"      # flash filesystem
    "udf"        # uncommon optical filesystem
  ];
}
