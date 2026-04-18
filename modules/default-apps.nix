# Pins default-browser / default-terminal on the Cinnamon taskbar and sets
# a custom menu applet icon + label. Xlet settings are per-user JSON,
# not dconf - we seed via /etc/skel + activation-script fallback.
#
# Instance-ids (3, 1) must match :N suffixes in modules/dconf.nix.

{ config, lib, pkgs, ... }:

let
  cfg = config.goudunix;

  terminalDesktop =
    "${pkgs.tilix}/share/applications/com.gexperts.Tilix.desktop";

  browserPkg = cfg.defaultBrowserPkg;

  # Browser vendors disagree on the .desktop filename, so scan.
  defaultAppsPkg = pkgs.runCommand "goudunix-default-apps" { } (''
    mkdir -p $out/share/applications
    ln -s ${terminalDesktop} \
      $out/share/applications/default-terminal.desktop
  '' + lib.optionalString (browserPkg != null) ''
    found=""
    for f in ${browserPkg}/share/applications/*.desktop; do
      [ -f "$f" ] || continue
      found="$f"
      break
    done
    if [ -z "$found" ]; then
      echo "goudunix-default-apps: no .desktop in ${browserPkg}/share/applications/" >&2
      exit 1
    fi
    ln -s "$found" $out/share/applications/default-browser.desktop
  '');

  pinnedApps =
    [ "nemo.desktop" ]
    ++ lib.optional (browserPkg != null) "default-browser.desktop"
    ++ [ "default-terminal.desktop" ];

  pinnedJson = builtins.toJSON {
    "__md5__" = "goudunix-seed";
    "pinned-apps" = {
      type = "generic";
      default = pinnedApps;
      value = pinnedApps;
    };
  };

  groupedWindowListId = "3";
  pinnedRel =
    ".config/cinnamon/spices/grouped-window-list@cinnamon.org/${groupedWindowListId}.json";

  # Full JSON + matching md5; otherwise Cinnamon runs _doUpgrade and
  # drops our values. menu-icon is a theme name, not a path.
  menuSchemaFile =
    "${pkgs.cinnamon-common}/share/cinnamon/applets/menu@cinnamon.org/settings-schema.json";

  menuInstanceFile = pkgs.runCommand "menu-instance.json"
    {
      nativeBuildInputs = [ pkgs.jq pkgs.coreutils ];
    } ''
      md5=$(md5sum ${menuSchemaFile} | cut -d' ' -f1)
      jq --arg md5 "$md5" '
        del(.layout)
        | with_entries(.value.value = (.value.value // .value.default))
        | .["menu-custom"].value = true
        | .["menu-icon"].value   = "nix-snowflake-white"
        | .["menu-label"].value  = "Menu"
        | . + {"__md5__": $md5}
      ' ${menuSchemaFile} > $out
    '';

  menuAppletId = "1";
  menuRel =
    ".config/cinnamon/spices/menu@cinnamon.org/${menuAppletId}.json";
in
{
  options.goudunix.defaultBrowserPkg = lib.mkOption {
    type = lib.types.nullOr lib.types.package;
    default = null;
    example = lib.literalExpression "pkgs.firefox";
    description = ''
      Browser picked in Calamares. Its .desktop is linked as
      default-browser.desktop on the taskbar. null = no pin.
    '';
  };

  config = {
    environment.systemPackages = [ defaultAppsPkg ];

    environment.etc."skel/${pinnedRel}".text = pinnedJson + "\n";
    environment.etc."skel/${menuRel}".source = menuInstanceFile;

    # Calamares' user bypasses skel, and its users job writes under
    # ~/.config as root - we chown-fix + seed if missing.
    system.activationScripts.goudunixPinnedApps = {
      text = ''
        pinnedSeed=${pkgs.writeText "grouped-window-list-pinned.json" (pinnedJson + "\n")}
        menuSeed=${menuInstanceFile}
        for home in /home/*; do
          [ -d "$home" ] || continue
          user=$(${pkgs.coreutils}/bin/stat -c %U "$home")
          group=$(${pkgs.coreutils}/bin/stat -c %G "$home")

          # Level-by-level so a new .config/ doesn't stay root-owned.
          for d in \
            "$home/.config" \
            "$home/.config/cinnamon" \
            "$home/.config/cinnamon/spices" \
            "$home/.config/cinnamon/spices/grouped-window-list@cinnamon.org" \
            "$home/.config/cinnamon/spices/menu@cinnamon.org"
          do
            ${pkgs.coreutils}/bin/install -d \
              -o "$user" -g "$group" -m 755 "$d"
          done

          for pair in \
            "${pinnedRel}|$pinnedSeed" \
            "${menuRel}|$menuSeed"
          do
            rel="''${pair%%|*}"
            src="''${pair##*|}"
            target="$home/$rel"
            if [ ! -e "$target" ]; then
              ${pkgs.coreutils}/bin/install -m 644 \
                -o "$user" -g "$group" "$src" "$target"
            fi
          done

          # --from=root:root leaves user-owned files alone.
          for dir in "$home/.config" "$home/.local" "$home/.cache"; do
            [ -d "$dir" ] || continue
            ${pkgs.coreutils}/bin/chown -R --from=root:root \
              "$user:$group" "$dir" 2>/dev/null || true
          done
        done
      '';
      deps = [ "users" ];
    };
  };
}
