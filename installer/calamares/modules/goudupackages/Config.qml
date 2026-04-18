// One property per widget - arrays don't survive Global.insert in 3.4.

import QtQuick 2.15
import QtQml 2.15

QtObject {
    id: config

    // Tab 1 - Internet
    //   "none" | "firefox" | "chromium" | "brave" | "vivaldi" | "google-chrome"
    property string browser: "none"
    //   "none" | "thunderbird" | "evolution" | "claws-mail"
    property string mailClient: "none"

    // Tab 2 - Productivity
    property bool prodLibreoffice: false
    property bool prodJoplin:      false
    property bool prodZim:         false
    property bool prodElement:     false
    property bool prodNextcloud:   false
    property bool prodLogseq:      false
    property bool prodKeepassxc:   false
    property bool prodOkular:      false
    property bool prodScribus:     false

    // Tab 3 - GFX & Multimedia
    property bool gfxVlc:        false
    property bool gfxGimp:       false
    property bool gfxPinta:      false
    property bool gfxAudacious:  false
    property bool gfxAudacity:   false
    property bool gfxObsStudio:  false
    property bool gfxKdenlive:   false
    property bool gfxInkscape:   false
    property bool gfxKrita:      false
    property bool gfxClementine: false

    // Tab 4 - Virtualization & containers
    //   vmGuest: "none" | "vmware" | "vbox"
    //   vmHost:  "none" | "vmware" | "vbox"
    //   container: "none" | "docker" | "podman"
    property string vmGuest:   "vmware"
    property string vmHost:    "none"
    property string container: "none"

    // Tab 5 - Development (editors + dev bundle)
    property bool editorVscode:   false
    property bool editorVscodium: false
    property bool editorNeovim:   false
    property bool editorZed:      false
    property bool dev:            false

    // Tab 6 - IT / automation
    property bool itAnsible:    false
    property bool itGlpiAgent:  false

    // GPU (read-only, shown on Tab 4).
    //   "nvidia" | "amd" | "intel" | "none"
    // Detection happens in main.py (lspci) at install time.
    property string gpu: "none"
    property string gpuLabel: qsTr("Detection in progress...")
}
