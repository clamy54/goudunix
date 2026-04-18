// Single Calamares step, six internal tabs. Bilingual via Qt.locale()
// (no .qm compilation). Arrays rebuilt from bools in onLeave.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.calamares.core 1.0

Page {
    id: root
    width: 800
    height: 600

    property Config config: Config {}

    function t(en, fr) {
        return Qt.locale().name.substring(0, 2) === "fr" ? fr : en;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pointSize: 14
            font.bold: true
            text: root.t("Goudunix - optional packages",
                         "Goudunix - paquets optionnels")
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.t(
                "Tick what you want installed. Nothing outside these tabs is pulled in; baseline apps (Tilix, Nemo, file-roller, GNOME utilities…) are always installed.",
                "Cochez ce que vous voulez installer. Rien en dehors de ces onglets n'est ajouté ; les applications de base (Tilix, Nemo, file-roller, utilitaires GNOME…) sont toujours installées.")
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true
            TabButton { text: root.t("Internet", "Internet") }
            TabButton { text: root.t("Productivity", "Productivité") }
            TabButton { text: root.t("GFX && Multimedia", "GFX && Multimédia") }
            TabButton { text: root.t("Virtualization", "Virtualisation") }
            TabButton { text: root.t("Development", "Développement") }
            TabButton { text: root.t("IT / Automation", "IT / Automatisation") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            // Tab 1 - Internet tools
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Web browser", "Navigateur Web")
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton { text: root.t("None", "Aucun"); checked: root.config.browser === "none";          onClicked: root.config.browser = "none" }
                            RadioButton { text: "Firefox";               checked: root.config.browser === "firefox";       onClicked: root.config.browser = "firefox" }
                            RadioButton { text: "Chromium";              checked: root.config.browser === "chromium";      onClicked: root.config.browser = "chromium" }
                            RadioButton { text: "Brave";                 checked: root.config.browser === "brave";         onClicked: root.config.browser = "brave" }
                            RadioButton { text: "Vivaldi";               checked: root.config.browser === "vivaldi";       onClicked: root.config.browser = "vivaldi" }
                            RadioButton { text: "Google Chrome";         checked: root.config.browser === "google-chrome"; onClicked: root.config.browser = "google-chrome" }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Mail client", "Client mail")
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton { text: root.t("None", "Aucun"); checked: root.config.mailClient === "none";        onClicked: root.config.mailClient = "none" }
                            RadioButton { text: "Thunderbird";           checked: root.config.mailClient === "thunderbird"; onClicked: root.config.mailClient = "thunderbird" }
                            RadioButton { text: "Evolution";             checked: root.config.mailClient === "evolution";   onClicked: root.config.mailClient = "evolution" }
                            RadioButton { text: "Claws Mail";            checked: root.config.mailClient === "claws-mail";  onClicked: root.config.mailClient = "claws-mail" }
                        }
                    }
                }
            }

            // Tab 2 - Productivity
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12
                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Productivity apps",
                                      "Applications de productivité")
                        ColumnLayout {
                            anchors.fill: parent
                            CheckBox { text: "LibreOffice"; checked: root.config.prodLibreoffice; onToggled: root.config.prodLibreoffice = checked }
                            CheckBox { text: "Joplin";      checked: root.config.prodJoplin;      onToggled: root.config.prodJoplin      = checked }
                            CheckBox { text: "Zim";         checked: root.config.prodZim;         onToggled: root.config.prodZim         = checked }
                            CheckBox { text: "Element";     checked: root.config.prodElement;     onToggled: root.config.prodElement     = checked }
                            CheckBox { text: "Nextcloud";   checked: root.config.prodNextcloud;   onToggled: root.config.prodNextcloud   = checked }
                            CheckBox { text: "Logseq";      checked: root.config.prodLogseq;      onToggled: root.config.prodLogseq      = checked }
                            CheckBox { text: "KeePassXC";   checked: root.config.prodKeepassxc;   onToggled: root.config.prodKeepassxc   = checked }
                            CheckBox { text: "Okular";      checked: root.config.prodOkular;      onToggled: root.config.prodOkular      = checked }
                            CheckBox { text: "Scribus";     checked: root.config.prodScribus;     onToggled: root.config.prodScribus     = checked }
                        }
                    }
                }
            }

            // Tab 3 - GFX & Multimedia
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12
                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("GFX & Multimedia apps",
                                      "Applications GFX & Multimédia")
                        ColumnLayout {
                            anchors.fill: parent
                            CheckBox { text: "VLC";        checked: root.config.gfxVlc;       onToggled: root.config.gfxVlc       = checked }
                            CheckBox { text: "GIMP";       checked: root.config.gfxGimp;      onToggled: root.config.gfxGimp      = checked }
                            CheckBox { text: "Pinta";      checked: root.config.gfxPinta;     onToggled: root.config.gfxPinta     = checked }
                            CheckBox { text: "Audacious";  checked: root.config.gfxAudacious; onToggled: root.config.gfxAudacious = checked }
                            CheckBox { text: "Audacity";   checked: root.config.gfxAudacity;  onToggled: root.config.gfxAudacity  = checked }
                            CheckBox { text: "OBS Studio"; checked: root.config.gfxObsStudio; onToggled: root.config.gfxObsStudio = checked }
                            CheckBox { text: "Kdenlive";   checked: root.config.gfxKdenlive;  onToggled: root.config.gfxKdenlive  = checked }
                            CheckBox { text: "Inkscape";   checked: root.config.gfxInkscape;  onToggled: root.config.gfxInkscape  = checked }
                            CheckBox { text: "Krita";      checked: root.config.gfxKrita;     onToggled: root.config.gfxKrita     = checked }
                            CheckBox { text: "Clementine"; checked: root.config.gfxClementine; onToggled: root.config.gfxClementine = checked }
                        }
                    }
                }
            }

            // Tab 4 - Virtualization & containers
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("GPU driver (auto-detected)",
                                      "Pilote GPU (autodétecté)")
                        Label {
                            anchors.fill: parent
                            wrapMode: Text.WordWrap
                            text: {
                                switch (root.config.gpu) {
                                    case "nvidia": return root.t("NVIDIA (proprietary driver)",
                                                                 "NVIDIA (pilote propriétaire)");
                                    case "amd":    return root.t("AMD (open-source amdgpu driver)",
                                                                 "AMD (pilote libre amdgpu)");
                                    case "intel":  return root.t("Intel (open-source i915 driver)",
                                                                 "Intel (pilote libre i915)");
                                    default:       return root.t("None / unknown - will be re-detected at install time.",
                                                                 "Aucun / inconnu - sera redétecté à l'installation.");
                                }
                            }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("VM guest tools", "Outils invité VM")
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton { text: root.t("None", "Aucun"); checked: root.config.vmGuest === "none";   onClicked: root.config.vmGuest = "none" }
                            RadioButton { text: "VMware";                checked: root.config.vmGuest === "vmware"; onClicked: root.config.vmGuest = "vmware" }
                            RadioButton { text: "VirtualBox";            checked: root.config.vmGuest === "vbox";   onClicked: root.config.vmGuest = "vbox" }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Virtualization software",
                                      "Logiciel de virtualisation")
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton { text: root.t("None", "Aucun"); checked: root.config.vmHost === "none";    onClicked: root.config.vmHost = "none" }
                            RadioButton { text: "VMware Workstation";    checked: root.config.vmHost === "vmware";  onClicked: root.config.vmHost = "vmware" }
                            RadioButton { text: "VirtualBox";            checked: root.config.vmHost === "vbox";    onClicked: root.config.vmHost = "vbox" }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Container runtime", "Runtime de conteneurs")
                        ColumnLayout {
                            anchors.fill: parent
                            RadioButton { text: root.t("None", "Aucun"); checked: root.config.container === "none";   onClicked: root.config.container = "none" }
                            RadioButton { text: "Docker";                checked: root.config.container === "docker"; onClicked: root.config.container = "docker" }
                            RadioButton { text: "Podman";                checked: root.config.container === "podman"; onClicked: root.config.container = "podman" }
                        }
                    }
                }
            }

            // Tab 5 - Development tools
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Code editors", "Éditeurs de code")
                        ColumnLayout {
                            anchors.fill: parent
                            CheckBox { text: "VS Code";  checked: root.config.editorVscode;   onToggled: root.config.editorVscode   = checked }
                            CheckBox { text: "VSCodium"; checked: root.config.editorVscodium; onToggled: root.config.editorVscodium = checked }
                            CheckBox { text: "Neovim";   checked: root.config.editorNeovim;   onToggled: root.config.editorNeovim   = checked }
                            CheckBox { text: "Zed";      checked: root.config.editorZed;      onToggled: root.config.editorZed      = checked }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("Development tools",
                                      "Outils de développement")
                        ColumnLayout {
                            anchors.fill: parent
                            CheckBox {
                                text: root.t("Install the development tools bundle (gcc, cmake, git, gdb, valgrind, …)",
                                             "Installer les outils de développement (gcc, cmake, git, gdb, valgrind, …)")
                                checked: root.config.dev
                                onToggled: root.config.dev = checked
                            }
                        }
                    }
                }
            }

            // Tab 6 - IT management / automation
            ScrollView {
                contentWidth: availableWidth
                clip: true
                ColumnLayout {
                    width: parent.width - 16
                    spacing: 12
                    GroupBox {
                        Layout.fillWidth: true
                        title: root.t("IT management / automation",
                                      "Gestion IT / automatisation")
                        ColumnLayout {
                            anchors.fill: parent
                            CheckBox { text: "Ansible";    checked: root.config.itAnsible;    onToggled: root.config.itAnsible    = checked }
                            CheckBox { text: "GLPI Agent"; checked: root.config.itGlpiAgent;  onToggled: root.config.itGlpiAgent  = checked }
                        }
                    }
                }
            }
        }
    }

    function onActivate() {}

    function nextAvailable() { return true; }

    function onLeave() {
        // One bool per option; main.py rebuilds the arrays.
        console.log("[goudupackages] onLeave:"
            + " browser=" + root.config.browser
            + " mail=" + root.config.mailClient
            + " prod=(lo=" + root.config.prodLibreoffice
            + " joplin=" + root.config.prodJoplin
            + " zim=" + root.config.prodZim
            + " element=" + root.config.prodElement
            + " nextcloud=" + root.config.prodNextcloud
            + " logseq=" + root.config.prodLogseq
            + " keepassxc=" + root.config.prodKeepassxc + ")"
            + " gfx=(vlc=" + root.config.gfxVlc
            + " gimp=" + root.config.gfxGimp
            + " pinta=" + root.config.gfxPinta
            + " audacious=" + root.config.gfxAudacious
            + " audacity=" + root.config.gfxAudacity
            + " obs=" + root.config.gfxObsStudio + ")"
            + " editors=(vscode=" + root.config.editorVscode
            + " vscodium=" + root.config.editorVscodium
            + " neovim=" + root.config.editorNeovim
            + " zed=" + root.config.editorZed + ")"
            + " dev=" + root.config.dev
            + " it=(ansible=" + root.config.itAnsible
            + " glpi=" + root.config.itGlpiAgent + ")");

        Global.insert("goudu.browser",       root.config.browser);
        Global.insert("goudu.mail_client",   root.config.mailClient);

        Global.insert("goudu.prod_libreoffice", root.config.prodLibreoffice);
        Global.insert("goudu.prod_joplin",      root.config.prodJoplin);
        Global.insert("goudu.prod_zim",         root.config.prodZim);
        Global.insert("goudu.prod_element",     root.config.prodElement);
        Global.insert("goudu.prod_nextcloud",   root.config.prodNextcloud);
        Global.insert("goudu.prod_logseq",      root.config.prodLogseq);
        Global.insert("goudu.prod_keepassxc",   root.config.prodKeepassxc);
        Global.insert("goudu.prod_okular",      root.config.prodOkular);
        Global.insert("goudu.prod_scribus",     root.config.prodScribus);

        Global.insert("goudu.gfx_vlc",        root.config.gfxVlc);
        Global.insert("goudu.gfx_gimp",       root.config.gfxGimp);
        Global.insert("goudu.gfx_pinta",      root.config.gfxPinta);
        Global.insert("goudu.gfx_audacious",  root.config.gfxAudacious);
        Global.insert("goudu.gfx_audacity",   root.config.gfxAudacity);
        Global.insert("goudu.gfx_obs_studio", root.config.gfxObsStudio);
        Global.insert("goudu.gfx_kdenlive",   root.config.gfxKdenlive);
        Global.insert("goudu.gfx_inkscape",   root.config.gfxInkscape);
        Global.insert("goudu.gfx_krita",      root.config.gfxKrita);
        Global.insert("goudu.gfx_clementine", root.config.gfxClementine);

        Global.insert("goudu.vm_guest",  root.config.vmGuest);
        Global.insert("goudu.vm_host",   root.config.vmHost);
        Global.insert("goudu.container", root.config.container);

        Global.insert("goudu.editor_vscode",   root.config.editorVscode);
        Global.insert("goudu.editor_vscodium", root.config.editorVscodium);
        Global.insert("goudu.editor_neovim",   root.config.editorNeovim);
        Global.insert("goudu.editor_zed",      root.config.editorZed);
        Global.insert("goudu.dev",             root.config.dev);

        Global.insert("goudu.it_ansible",    root.config.itAnsible);
        Global.insert("goudu.it_glpi_agent", root.config.itGlpiAgent);
    }
}
