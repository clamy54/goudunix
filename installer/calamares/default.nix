# Drop-in replacement for calamares-nixos-extensions with Goudunix overlays
# (configs, nixos main.py, goudupackages view module, branding).

{ stdenv
, lib
, calamares
, calamares-nixos-extensions
, cmake
, pkg-config
, qt6
, kdePackages
, yaml-cpp
}:

stdenv.mkDerivation {
  pname = "calamares-nixos-extensions-goudunix";
  inherit (calamares-nixos-extensions) version;

  src = ./.;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    # CalamaresConfig.cmake gates KF6 discovery on find_package(ECM).
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    calamares
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qttools
    kdePackages.kcoreaddons
    yaml-cpp
  ];

  cmakeDir = "../modules/goudupackages";

  dontWrapQtApps = true;

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  installPhase = ''
    runHook preInstall

    sofile="$(pwd)/libcalamares_viewmodule_goudupackages.so"
    if [ ! -f "$sofile" ]; then
      echo "FATAL: goudupackages shim was not produced by cmake/make" >&2
      ls -la
      exit 1
    fi

    # Start from upstream, then overlay our files.
    mkdir -p $out
    cp -rL ${calamares-nixos-extensions}/. $out/
    chmod -R u+w $out

    install -Dm644 $src/settings.conf $out/etc/calamares/settings.conf
    substituteInPlace $out/etc/calamares/settings.conf \
      --subst-var-by out "$out"
    install -Dm644 $src/users.conf     $out/etc/calamares/modules/users.conf
    install -Dm644 $src/partition.conf $out/etc/calamares/modules/partition.conf

    install -Dm644 $src/modules/nixos/main.py \
      $out/lib/calamares/modules/nixos/main.py

    # QML files land in the branding dir; QmlViewStep finds them via
    # qmlSearch: BrandingOnly.
    mkdir -p $out/lib/calamares/modules/goudupackages
    install -Dm755 "$sofile" \
      -t $out/lib/calamares/modules/goudupackages/
    install -Dm644 $src/modules/goudupackages/module.desc \
      -t $out/lib/calamares/modules/goudupackages/
    install -Dm644 $src/modules/goudupackages/goudupackages.conf \
      $out/etc/calamares/modules/goudupackages.conf

    # Branding: reuse the upstream NixOS snowflake as productIcon/Logo
    # (required by Calamares 3.3+).
    mkdir -p $out/share/calamares/branding/goudunix
    install -Dm644 \
      $src/branding/goudunix/branding.desc \
      $src/branding/goudunix/show.qml \
      $src/branding/goudunix/notesqml@unfree.qml \
      -t $out/share/calamares/branding/goudunix/
    install -Dm644 \
      ${calamares-nixos-extensions}/share/calamares/branding/nixos/nix-snowflake.svg \
      ${calamares-nixos-extensions}/share/calamares/branding/nixos/white.png \
      -t $out/share/calamares/branding/goudunix/
    install -Dm644 \
      $src/modules/goudupackages/goudupackages.qml \
      $src/modules/goudupackages/Config.qml \
      -t $out/share/calamares/branding/goudunix/

    runHook postInstall
  '';

  meta = {
    description =
      "Calamares extensions with Goudunix branding and goudupackages selector";
    inherit (calamares-nixos-extensions.meta) platforms license;
  };
}
