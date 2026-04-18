// Minimal slideshow shown during nixos-install.
//
// Bilingual strings via a tiny Qt.locale() helper - same pattern as
// goudupackages.qml. English source, French fallback for Calamares users
// who picked "Français" on the Location step.
//
// TODO: replace with actual Goudunix slides (screenshots, feature highlights).

import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function t(en, fr) {
        return Qt.locale().name.substring(0, 2) === "fr" ? fr : en;
    }

    Timer {
        interval: 12000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Text {
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width * 0.8
            font.pointSize: 18
            color: "#333"
            text: presentation.t(
                "Goudunix - hardened NixOS, ready to use.\n"
                + "A Cinnamon-based desktop environment.",
                "Goudunix - NixOS durci, prêt à l'emploi.\n"
                + "Un environnement de bureau basé sur Cinnamon.")
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 18
            color: "#333"
            text: presentation.t(
                "Your software selection\n"
                + "is declared in /etc/nixos/modules/packages.nix.\n\n"
                + "Editable afterwards: `sudo nixos-rebuild switch`.",
                "Votre sélection de logiciels\n"
                + "sera déclarée dans /etc/nixos/modules/packages.nix.\n\n"
                + "Éditable après-coup : `sudo nixos-rebuild switch`.")
        }
    }

    function onActivate()  {}
    function onLeave()     {}
}
