// Goudunix override of upstream calamares-nixos-extensions'
// branding/nixos/notesqml@unfree.qml. Two substantive changes vs upstream:
//
//  1. `checked: true` on the CheckBox: Goudunix ships drivers and apps
//     that are frequently unfree (NVIDIA, Brave, Vivaldi, Chrome, VS Code),
//     so the expected default for a Goudunix install is to allow them.
//     Users can still untick for a pure-FOSS install.
//
//  2. Bilingual text via a tiny Qt.locale() helper - upstream uses qsTr()
//     which falls back to the English source when no .qm is loaded, which
//     left French Calamares users staring at English on this page.

import io.calamares.core

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Page {
    id: root
    width: parent.width
    height: parent.height

    function t(en, fr) {
        return Qt.locale().name.substring(0, 2) === "fr" ? fr : en;
    }

    // Seed GlobalStorage with the default before the user interacts, so
    // main.py reads `true` even if the page is clicked-through without
    // ticking/unticking (onCheckedChanged only fires on changes).
    Component.onCompleted: Global.insert("nixos_allow_unfree", true)

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.smallSpacing

        Column {
            Layout.fillWidth: true

            Text {
                text: root.t(
                    "NixOS is fully open source, but it also provides optional software packages that do not respect users' freedom to run, copy, distribute, study, change and improve the software, and are commonly not open source. By default such \"unfree\" packages are not allowed, but you can enable it here. If you check this box, you agree that unfree software may be installed which might have additional End User License Agreements (EULAs) that you need to agree to. If not enabled, some hardware (notably Nvidia GPUs and some WiFi chips) might not work or not work optimally.<br/>",
                    "NixOS est entièrement open source, mais propose aussi des paquets optionnels qui ne respectent pas les libertés de l'utilisateur (exécuter, copier, distribuer, étudier, modifier, améliorer) et qui ne sont généralement pas open source. Par défaut ces paquets « non-libres » sont interdits, mais vous pouvez les autoriser ici. En cochant cette case, vous acceptez que des logiciels non-libres puissent être installés, avec leurs propres contrats de licence (CLUF) à accepter. Sans cette option, certains matériels (notamment les GPU Nvidia et certaines puces Wi-Fi) peuvent ne pas fonctionner ou fonctionner moins bien.<br/>")
                width: parent.width
                wrapMode: Text.WordWrap
            }

            CheckBox {
                text: root.t("Allow unfree software",
                             "Autoriser les logiciels non-libres")
                checked: true

                onCheckedChanged: {
                    Global.insert("nixos_allow_unfree", checked)
                }
            }
        }
    }
}
