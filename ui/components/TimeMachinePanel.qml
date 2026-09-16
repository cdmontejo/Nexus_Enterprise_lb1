import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"

Item {
    id: root

    property var historyEntries: []
    property bool integrityOk: true
    property bool isEnglish: configManager ? (configManager.language === "en") : false

    Component.onCompleted: refresh()

    function refresh() {
        if (configManager) {
            historyEntries = configManager.listHistory()
            integrityOk = configManager.verifyIntegrity()
        }
    }

    Connections {
        target: configManager
        function onHistoryChanged() { root.refresh() }
        function onTelemetryUpdated() { root.refresh() }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            height: 42
            radius: Theme.radiusMd
            color: root.integrityOk ? Qt.rgba(0.22, 1, 0.08, 0.10) : Qt.rgba(1, 0.27, 0.27, 0.12)
            border.width: 1
            border.color: root.integrityOk ? Theme.accentSuccess : Theme.accentDanger

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: root.integrityOk ? Theme.accentSuccess : Theme.accentDanger
                }
                Text {
                    text: root.integrityOk
                          ? (isEnglish ? "Integrity certified — SHA-256 seal matches" : "Integridad certificada — sello SHA-256 coincide")
                          : (isEnglish ? "Security Alert: config.json checksum mismatch" : "Alerta de seguridad: config.json no coincide con su sello SHA-256")
                    color: Theme.textPrimary
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: isEnglish ? "Time Machine (Configuration Snapshots)" : "Máquina del Tiempo (Versiones de Configuración)"
                color: Theme.textPrimary
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: (root.historyEntries ? root.historyEntries.length : 0) + (isEnglish ? " snapshots saved" : " versiones guardadas")
                color: Theme.textSecondary
                font.pixelSize: 12
            }
            NexusButton {
                text: isEnglish ? "Refresh" : "Actualizar"
                variant: "secondary"
                implicitHeight: 32
                onClicked: root.refresh()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusMd
            color: Theme.bgElevated
            border.width: 1
            border.color: Theme.borderSubtle
            clip: true

            ScrollView {
                id: historyScroll
                anchors.fill: parent
                anchors.margins: 10
                clip: true

                ListView {
                    id: historyList
                    width: historyScroll.width - 16
                    spacing: 8
                    model: root.historyEntries

                    delegate: Rectangle {
                        width: historyList.width
                        height: 56
                        radius: Theme.radiusSm
                        color: Theme.bgSurface
                        border.width: 1
                        border.color: Theme.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: Qt.rgba(0.12, 0.66, 1.0, 0.15)
                                Text {
                                    anchors.centerIn: parent
                                    text: "🕰"
                                    font.pixelSize: 13
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: modelData.saved_at ? modelData.saved_at.replace("T", "   •   ") : modelData.entry_id
                                    color: Theme.textPrimary
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Text {
                                    text: modelData.entry_id + "  (" + (modelData.size_bytes / 1024).toFixed(1) + " KB)"
                                    color: Theme.textSecondary
                                    font.pixelSize: 11
                                }
                            }

                            NexusButton {
                                text: isEnglish ? "Restore" : "Restaurar"
                                variant: "secondary"
                                implicitHeight: 34
                                onClicked: {
                                    configManager.restoreVersion(modelData.entry_id)
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.historyEntries || root.historyEntries.length === 0
                text: isEnglish ? "No snapshots available yet. Save changes to start history." : "Todavía no hay versiones guardadas. Guarda un cambio para empezar."
                color: Theme.textSecondary
                font.pixelSize: 13
            }
        }
    }
}
