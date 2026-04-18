# ZSH + oh-my-zsh (with custom kali-like theme), default shell, vim.

{ config, lib, pkgs, ... }:

let
  # Custom oh-my-zsh theme: kali-like (pinned to release 2.1 for reproducibility)
  kali-like-zsh-theme = pkgs.fetchFromGitHub {
    owner = "clamy54";
    repo = "kali-like-zsh-theme";
    rev = "2.1";
    sha256 = "sha256-cwNlIut8VucrnISbAUQ2ALvGX+ifgZa6hnctiUaC7MM=";
  };

  # Wrapper derivation to place the theme file where oh-my-zsh expects it
  kali-like-zsh-theme-pkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "kali-like-zsh-theme";
    version = "unstable";
    src = kali-like-zsh-theme;
    installPhase = ''
      mkdir -p $out/share/zsh/themes
      cp *.zsh-theme $out/share/zsh/themes/
    '';
  };
in
{
  programs.zsh = {
    enable = true;
    # Kill the zsh-newuser-install wizard permanently by ensuring ~/.zshrc
    # exists before zsh even thinks about prompting. shellInit lands in
    # /etc/zshenv - the very first file zsh sources on *every* startup path,
    # well before the wizard-triggering check. The previous workaround
    # (overriding the function from interactiveShellInit) fired too late:
    # the wizard had already printed its menu.
    shellInit = ''
      if [ -w "$HOME" ] && [ ! -e "$HOME/.zshrc" ]; then
        : > "$HOME/.zshrc"
      fi
    '';
    # Run fastfetch on every interactive shell (skip dumb terminals like
    # Emacs tramp, non-tty sessions, and scp/rsync subshells).
    #
    # Also source Tilix' VTE integration snippet - this registers an OSC 7
    # precmd hook so Tilix knows the shell's current directory, which
    # silences the "Please enable prompt tracking" banner that links to
    # https://gnunn1.github.io/tilix-web/manual/vteconfig/ on first run.
    interactiveShellInit = ''
      if [ -n "$TILIX_ID" ] || [ -n "$VTE_VERSION" ]; then
        . ${pkgs.vte}/etc/profile.d/vte.sh
      fi

      if [[ -o interactive ]] && [[ -t 1 ]] && [[ "$TERM" != "dumb" ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
    ohMyZsh = {
      enable = true;
      theme = "kali-like";
      customPkgs = [ kali-like-zsh-theme-pkg ];
      plugins = [ "git" "sudo" "command-not-found" ];
    };
  };

  # Default shell for all users
  users.defaultUserShell = pkgs.zsh;

  # ──────────────────────────────────────────────
  # Vim (system-wide configuration)
  # ──────────────────────────────────────────────
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.etc."vimrc.local".text = ''
    set paste
    set mouse=r
    syntax on
  '';

  environment.variables.VIMINIT = "source /etc/vimrc.local";
}
