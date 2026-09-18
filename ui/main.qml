import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"
import "theme"

ApplicationWindow {
    id: appWindow
    visible: true
    visibility: Window.Maximized
    width: 1240
    height: 800
    minimumWidth: 980
    minimumHeight: 660

    property string currentLang: configManager ? configManager.language : "es"
    property bool isEnglish: currentLang === "en"
    property string currentTheme: configManager ? configManager.theme : "dark"

    onCurrentThemeChanged: {
        Theme.activeTheme = currentTheme
    }
    Component.onCompleted: {
        Theme.activeTheme = currentTheme
        if (configManager) {
            Theme.accentPrimary = configManager.accentColor
        }
    }

    title: isEnglish ? "NEXUS Enterprise v3.2 — Transactional System & Local AI" : "NEXUS Enterprise v3.2 — Sistema Transaccional & IA Local"
    color: Theme.bgBase

    Connections {
        target: configManager
        function onNotificationReceived(type, title, message) {
            appToast.show(type, title, message)
        }
        function onIntegrityAlert(msg) {
            appToast.show("error", isEnglish ? "⚠️ Integrity Alert" : "⚠️ Alerta de Integridad", msg)
        }
        function onAccentColorChanged(clr) {
            Theme.accentPrimary = clr
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: orb1
            width: 580; height: 580; radius: 290
            color: Theme.orb1Color
            x: -100; y: -100
            Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: 60; duration: 11000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -100; duration: 11000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: 40; duration: 13000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -100; duration: 13000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.15; duration: 7000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.95; duration: 7000; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            id: orb2
            width: 500; height: 500; radius: 250
            color: Theme.orb2Color
            x: appWindow.width - 400; y: appWindow.height - 400
            Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: appWindow.width - 480; duration: 14000; easing.type: Easing.InOutSine }
                NumberAnimation { to: appWindow.width - 400; duration: 14000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: appWindow.height - 480; duration: 9500; easing.type: Easing.InOutSine }
                NumberAnimation { to: appWindow.height - 400; duration: 9500; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.12; duration: 8000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.92; duration: 8000; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            id: orb3
            width: 360; height: 360; radius: 180
            color: Theme.orb3Color
            x: appWindow.width / 2 - 180; y: appWindow.height / 2 - 180
            Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: appWindow.width / 2 - 80; duration: 16000; easing.type: Easing.InOutSine }
                NumberAnimation { to: appWindow.width / 2 - 180; duration: 16000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: appWindow.height / 2 - 240; duration: 12000; easing.type: Easing.InOutSine }
                NumberAnimation { to: appWindow.height / 2 - 180; duration: 12000; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            id: orb4
            width: 280; height: 280; radius: 140
            color: Theme.orb4Color
            x: 100; y: appWindow.height - 300
            Behavior on color { ColorAnimation { duration: Theme.animSlow } }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: appWindow.height - 200; duration: 10000; easing.type: Easing.InOutSine }
                NumberAnimation { to: appWindow.height - 300; duration: 10000; easing.type: Easing.InOutSine }
            }
        }

        Repeater {
            model: [
                { initX: 120, initY: 180, sz: 5, dur: 4200 },
                { initX: 380, initY: 90,  sz: 7, dur: 5600 },
                { initX: 720, initY: 260, sz: 6, dur: 4800 },
                { initX: 890, initY: 480, sz: 8, dur: 6200 },
                { initX: 310, initY: 620, sz: 5, dur: 5100 }
            ]
            delegate: Rectangle {
                x: modelData.initX; y: modelData.initY
                width: modelData.sz; height: modelData.sz; radius: modelData.sz / 2
                color: Theme.accentPrimary
                opacity: 0.25
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.65; duration: modelData.dur; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.15; duration: modelData.dur; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation { to: modelData.initY - 24; duration: modelData.dur * 1.5; easing.type: Easing.InOutSine }
                    NumberAnimation { to: modelData.initY; duration: modelData.dur * 1.5; easing.type: Easing.InOutSine }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 268

            Rectangle {
                anchors.fill: sidebarIsland
                anchors.margins: -3
                radius: sidebarIsland.radius + 3
                color: "transparent"
                border.color: Theme.activeTheme === "dark" ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.08)
                border.width: 3
                z: -1
            }

            Rectangle {
                id: sidebarIsland
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                anchors.leftMargin: 12
                anchors.rightMargin: 6
                radius: 22
                clip: true
                color: Theme.glassFill
                border.color: Theme.glassBorder
                border.width: 1.5

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.40
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.glassSheen }
                        GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 0.01) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Theme.activeTheme === "dark" ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.30) }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    anchors.bottomMargin: 12
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        height: 38

                        Rectangle {
                            anchors.centerIn: parent
                            width: 160; height: 24; radius: 12
                            color: Theme.activeTheme === "dark" ? Qt.rgba(0.04, 0.08, 0.14, 0.75) : Qt.rgba(1, 1, 1, 0.85)
                            border.color: Theme.glassBorder
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7

                                Rectangle {
                                    width: 7; height: 7; radius: 3.5
                                    color: (configManager && configManager.configExists) ? Theme.accentSuccess : Theme.accentDanger
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.35; duration: 1100; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 1.0; duration: 1100; easing.type: Easing.InOutSine }
                                    }
                                }

                                Text {
                                    text: isEnglish ? "NEXUS • SYSTEM ONLINE" : "NEXUS • SISTEMA ACTIVO"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 0.8
                                    color: Theme.textPrimary
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "transparent"


                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 12
                            spacing: 12

                            Rectangle {
                                width: 42; height: 42; radius: 10; color: "transparent"
                                Image {
                                    anchors.fill: parent
                                    source: "assets/logo_nexus.jpg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }

                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true
                                Text {
                                    text: "NEXUS"
                                    font.pixelSize: 20; font.bold: true; font.letterSpacing: 2
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Enterprise v3.2"
                                    font.pixelSize: 10; color: Theme.textSecondary; font.letterSpacing: 0.5
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 1
                        color: Theme.glassBorder
                    }

                    Item { height: 10 }

                    Repeater {
                        model: [
                            { icon: "assets/panel principal logo.jpg",       labelEs: "Panel Principal",         labelEn: "Dashboard",            idx: 0 },
                            { icon: "assets/configuracion general logo.jpg", labelEs: "Configuración General",   labelEn: "General Settings",     idx: 1 },
                            { icon: "assets/documentos y archivos logo.jpg", labelEs: "Documentos y Archivos",   labelEn: "Documents & Files",    idx: 2 },
                            { icon: "",                                       labelEs: "Asistente NEXUS AI",      labelEn: "NEXUS AI Assistant",   idx: 3 },
                            { icon: "assets/diagnostico y telerimetria logo.jpg", labelEs: "Diagnóstico y Telemetría", labelEn: "System Diagnostics", idx: 4 }
                        ]

                        delegate: Item {
                            Layout.fillWidth: true
                            height: 46

                            Rectangle {
                                width: 3
                                height: parent.height * 0.65
                                anchors.verticalCenter: parent.verticalCenter
                                color: viewStack.currentIndex === modelData.idx ? Theme.accentPrimary : "transparent"
                                radius: 2
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 8
                                radius: Theme.radiusMd
                                color: viewStack.currentIndex === modelData.idx
                                       ? Theme.glassHighlight
                                       : (hoverMa.containsMouse ? Qt.rgba(1,1,1, Theme.activeTheme === "dark" ? 0.05 : 0.30) : "transparent")

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                Rectangle {
                                    visible: viewStack.currentIndex === modelData.idx
                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                    height: parent.height * 0.5; radius: parent.radius
                                    color: Qt.rgba(1,1,1, 0.06)
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14; anchors.rightMargin: 10
                                    spacing: 12

                                    Item {
                                        width: 20; height: 20
                                        Image {
                                            anchors.fill: parent
                                            visible: modelData.icon !== ""
                                            source: modelData.icon
                                            fillMode: Image.PreserveAspectFit; smooth: true
                                            opacity: viewStack.currentIndex === modelData.idx ? 1.0 : 0.7
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            visible: modelData.icon === ""
                                            text: "🧠"; font.pixelSize: 15
                                            color: viewStack.currentIndex === modelData.idx ? Theme.accentPrimary : Theme.textSecondary
                                        }
                                    }

                                    Text {
                                        text: isEnglish ? modelData.labelEn : modelData.labelEs
                                        font.pixelSize: 12
                                        font.weight: viewStack.currentIndex === modelData.idx ? Font.DemiBold : Font.Normal
                                        color: viewStack.currentIndex === modelData.idx ? Theme.textPrimary : Theme.textSecondary
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    }

                                    Rectangle {
                                        visible: modelData.idx === 4
                                        width: 7; height: 7; radius: 4
                                        color: (configManager && configManager.configExists) ? Theme.accentSuccess : Theme.accentDanger
                                    }
                                }

                                MouseArea {
                                    id: hoverMa
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        viewStack.currentIndex = modelData.idx
                                        if (modelData.idx === 2) configManager.refresh_telemetry()
                                        if (modelData.idx === 4) configManager.refresh_telemetry()
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
                        height: 62; radius: Theme.radiusMd
                        color: Qt.rgba(1,1,1, Theme.activeTheme === "dark" ? 0.06 : 0.50)
                        border.color: Theme.glassBorder; border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 10

                            RoundedAvatar {
                                width: 38; height: 38
                                source: configManager ? configManager.profilePicture : ""
                                fallbackInitials: configManager && configManager.username ? configManager.username.charAt(0).toUpperCase() : "U"
                                borderColor: Theme.accentPrimary
                                borderWidth: 1.5
                            }

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text {
                                    text: configManager ? configManager.username : "Usuario"
                                    font.pixelSize: 12; font.bold: true; color: Theme.textPrimary
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }
                                Text {
                                    text: (configManager && configManager.theme === "dark")
                                          ? (isEnglish ? "Dark Theme" : "Tema Oscuro")
                                          : (isEnglish ? "Light Theme" : "Tema Claro")
                                    font.pixelSize: 10; color: Theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                id: viewStack
                anchors.fill: parent
                currentIndex: 0

                ScrollView {
                    contentWidth: width
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            height: 64
                            color: Theme.bgSurface
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width; height: 1
                                color: Theme.borderSubtle
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 28
                                anchors.rightMargin: 24
                                Text {
                                    text: isEnglish ? "Dashboard" : "Panel Principal"
                                    font.pixelSize: 22
                                    font.bold: true
                                    color: Theme.textPrimary
                                    Layout.fillWidth: true
                                }
                                Text {
                                    id: clockText
                                    font.pixelSize: 13
                                    color: Theme.textSecondary
                                    Timer {
                                        interval: 1000; repeat: true; running: true
                                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss  •  dd MMM yyyy")
                                    }
                                    Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm:ss  •  dd MMM yyyy")
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.margins: 28
                            spacing: 22

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 440
                                    height: 220
                                    radius: Theme.radiusLg
                                    color: Theme.bgSurface
                                    border.color: Theme.borderSubtle
                                    border.width: 1
                                    clip: true

                                    Rectangle {
                                        width: parent.width; height: 4
                                        anchors.top: parent.top
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: Theme.accentPrimary }
                                            GradientStop { position: 1.0; color: Theme.accentPurple }
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 10

                                        RoundedAvatar {
                                            Layout.alignment: Qt.AlignHCenter
                                            width: 90; height: 90
                                            source: configManager ? configManager.profilePicture : ""
                                            fallbackInitials: configManager && configManager.username ? configManager.username.charAt(0).toUpperCase() : "U"
                                            borderColor: Theme.accentPrimary
                                            borderWidth: 3
                                        }

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: configManager ? configManager.username : "Usuario"
                                            font.pixelSize: 17
                                            font.bold: true
                                            color: Theme.textPrimary
                                        }

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: isEnglish ? "Status: Operational (100% OK)" : "Estado: Configuración Óptima"
                                            font.pixelSize: 12
                                            color: Theme.accentSuccess
                                            font.weight: Font.Medium
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 220
                                    radius: Theme.radiusLg
                                    color: Theme.bgSurface
                                    border.color: Theme.borderSubtle
                                    border.width: 1
                                    clip: true

                                    Rectangle {
                                        width: parent.width; height: 4
                                        anchors.top: parent.top
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: Theme.accentSuccess }
                                            GradientStop { position: 1.0; color: Theme.accentPrimary }
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 22
                                        anchors.topMargin: 24
                                        spacing: 12

                                        Text {
                                            text: isEnglish ? "System Status & Integrity" : "Estado del Sistema e Integridad"
                                            font.pixelSize: 15
                                            font.bold: true
                                            color: Theme.textPrimary
                                        }

                                        Repeater {
                                            model: [
                                                { label: "config.json", val: (configManager && configManager.configExists) ? (isEnglish ? "Valid (Active)" : "Válido (Activo)") : (isEnglish ? "Missing" : "Ausente"), ok: (configManager && configManager.configExists) },
                                                { label: isEnglish ? "Encoding" : "Codificación", val: "UTF-8 (100% Íntegro)", ok: true },
                                                { label: "Backup .bak", val: (configManager && configManager.backupExists) ? (isEnglish ? "Certified" : "Certificado") : (isEnglish ? "Pending" : "Sin crear"), ok: (configManager && configManager.backupExists) },
                                                { label: isEnglish ? "Integrity Seal" : "Sello SHA-256", val: (configManager && configManager.verifyIntegrity()) ? (isEnglish ? "Verified Match" : "Verificado (Coincide)") : (isEnglish ? "Mismatch Alert" : "Alerta de Alteración"), ok: (configManager && configManager.verifyIntegrity()) }
                                            ]

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10

                                                Rectangle {
                                                    width: 22; height: 22; radius: 4
                                                    color: modelData.ok ? Qt.rgba(0.06, 0.72, 0.51, 0.15) : Qt.rgba(0.94, 0.27, 0.27, 0.15)
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.ok ? "✓" : "✕"
                                                        font.pixelSize: 12
                                                        font.bold: true
                                                        color: modelData.ok ? Theme.accentSuccess : Theme.accentDanger
                                                    }
                                                }

                                                Text {
                                                    text: modelData.label
                                                    font.pixelSize: 13
                                                    color: Theme.textSecondary
                                                    Layout.preferredWidth: 120
                                                }

                                                Text {
                                                    text: modelData.val
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: modelData.ok ? Theme.accentSuccess : Theme.accentDanger
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 520
                                    height: 240
                                    radius: Theme.radiusLg
                                    color: Theme.bgSurface
                                    border.color: Theme.borderSubtle
                                    border.width: 1
                                    clip: true

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 10

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text {
                                                text: isEnglish ? "Recent Configuration Activity" : "Actividad Reciente del Sistema"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: Theme.textPrimary
                                                Layout.fillWidth: true
                                            }
                                            Rectangle {
                                                width: 8; height: 8; radius: 4
                                                color: Theme.accentSuccess
                                            }
                                            Text {
                                                text: isEnglish ? "Live" : "En vivo"
                                                font.pixelSize: 11
                                                color: Theme.accentSuccess
                                            }
                                        }

                                        ListView {
                                            id: dashLogList
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            spacing: 6
                                            model: ListModel { id: dashLogModel }
                                            delegate: RowLayout {
                                                width: dashLogList.width
                                                spacing: 8
                                                Rectangle {
                                                    width: 6; height: 6; radius: 3
                                                    color: model.line.indexOf("ERROR") !== -1 ? Theme.accentDanger
                                                         : model.line.indexOf("WARNING") !== -1 ? Theme.statusWarn
                                                         : Theme.accentPrimary
                                                }
                                                Text {
                                                    text: model.line
                                                    font.pixelSize: 11
                                                    color: model.line.indexOf("ERROR") !== -1 ? Theme.accentDanger
                                                         : model.line.indexOf("WARNING") !== -1 ? Theme.statusWarn
                                                         : Theme.textSecondary
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }
                                            }
                                            onCountChanged: Qt.callLater(positionViewAtEnd)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 240
                                    radius: Theme.radiusLg
                                    color: Theme.bgSurface
                                    border.color: Theme.borderSubtle
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 10

                                        Text {
                                            text: isEnglish ? "Quick Actions" : "Acciones Rápidas"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: Theme.textPrimary
                                        }

                                        NexusButton {
                                            Layout.fillWidth: true
                                            text: isEnglish ? "💾  Save Configuration (Safe-Write)" : "💾  Guardar Configuración (Safe-Write)"
                                            variant: "primary"
                                            onClicked: configManager.save_configuration()
                                        }
                                        NexusButton {
                                            Layout.fillWidth: true
                                            text: isEnglish ? "🔍  Verify SHA-256 Checksum" : "🔍  Verificar Sello SHA-256"
                                            variant: "secondary"
                                            onClicked: {
                                                var ok = configManager.verifyIntegrity()
                                                appToast.show(
                                                    ok ? "success" : "error",
                                                    ok ? (isEnglish ? "Integrity Certified" : "Integridad Certificada") : (isEnglish ? "Integrity Alert" : "Alerta de Integridad"),
                                                    ok ? (isEnglish ? "config.json matches its SHA-256 checksum." : "config.json está 100% íntegro. El sello coincide.") : (isEnglish ? "Checksum mismatch detected." : "El sello SHA-256 no coincide. Posible alteración externa.")
                                                )
                                            }
                                        }
                                        NexusButton {
                                            Layout.fillWidth: true
                                            text: isEnglish ? "📁  Open File & Document Manager" : "📁  Abrir Gestor de Archivos y Documentos"
                                            variant: "secondary"
                                            onClicked: viewStack.currentIndex = 2
                                        }
                                        NexusButton {
                                            Layout.fillWidth: true
                                            text: isEnglish ? "↺  Restore Factory Defaults" : "↺  Restablecer Valores de Fábrica"
                                            variant: "danger"
                                            onClicked: configManager.reset_to_defaults()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                ScrollView {
                    contentWidth: width
                    clip: true

                    ColumnLayout {
                        width: Math.min(parent.width - 56, 920)
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Layout.topMargin: 24
                        Layout.bottomMargin: 36

                        ColumnLayout {
                            spacing: 4
                            Text {
                                text: isEnglish ? "General Settings & Preferences" : "Configuración General y Preferencias"
                                font.pixelSize: 22; font.bold: true; color: Theme.textPrimary
                            }
                            Text {
                                text: isEnglish ? "Safe-Write transactional persistence with strict UTF-8 validation." : "Persistencia transaccional Safe-Write con validación UTF-8 estricta."
                                font.pixelSize: 13; color: Theme.textSecondary
                            }
                        }

                        // Perfil
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: profileCol.implicitHeight + 36
                            radius: Theme.radiusLg
                            color: Theme.bgSurface
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                id: profileCol
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 16

                                Text {
                                    text: isEnglish ? "User Profile" : "Perfil de Usuario"
                                    font.pixelSize: 15; font.bold: true; color: Theme.textPrimary
                                }

                                RowLayout {
                                    Layout.fillWidth: true; spacing: 24

                                    ColumnLayout {
                                        spacing: 8
                                        RoundedAvatar {
                                            width: 76; height: 76
                                            source: configManager ? configManager.profilePicture : ""
                                            fallbackInitials: configManager && configManager.username ? configManager.username.charAt(0).toUpperCase() : "U"
                                            borderColor: Theme.accentPrimary
                                            borderWidth: 2
                                        }
                                        NexusButton {
                                            text: isEnglish ? "Change Picture..." : "Cambiar Foto..."
                                            variant: "secondary"
                                            onClicked: configManager.open_profile_picker_dialog()
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 6
                                        Text {
                                            text: isEnglish ? "Display Name (UTF-8 supported — accents, ñ, special chars):" : "Nombre de Usuario (Soporta caracteres UTF-8, tildes y ñ):"
                                            font.pixelSize: 12; color: Theme.textSecondary
                                        }
                                        TextField {
                                            id: txtUsername
                                            Layout.fillWidth: true; height: 42
                                            text: configManager ? configManager.username : ""
                                            font.pixelSize: 14; color: Theme.textPrimary
                                            placeholderText: "Ej. César Ñandú de España"
                                            background: Rectangle {
                                                radius: Theme.radiusMd; color: Theme.bgInput
                                                border.color: txtUsername.activeFocus ? Theme.accentPrimary : Theme.borderSubtle
                                                border.width: 1.5
                                            }
                                            onTextChanged: {
                                                if (configManager) configManager.username = text
                                            }
                                        }
                                        Text {
                                            text: isEnglish ? "Verified: 100% Strict UTF-8 saved in data/config.json." : "Verificado: Codificación UTF-8 estricta guardada en data/config.json."
                                            font.pixelSize: 11; color: Theme.textDisabled
                                        }
                                    }
                                }
                            }
                        }

                        // Apariencia
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: appearCol.implicitHeight + 36
                            radius: Theme.radiusLg
                            color: Theme.bgSurface
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                id: appearCol
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 18

                                Text {
                                    text: isEnglish ? "Appearance & Visual Customization" : "Apariencia y Personalización Visual"
                                    font.pixelSize: 15; font.bold: true; color: Theme.textPrimary
                                }

                                RowLayout {
                                    Layout.fillWidth: true; spacing: 16
                                    Text {
                                        text: isEnglish ? "Interface Theme:" : "Tema de la Interfaz:"
                                        font.pixelSize: 13; color: Theme.textSecondary; Layout.preferredWidth: 140
                                    }
                                    Repeater {
                                        
                                        model: [
                                            { icon: "assets/oscuro logo.jpg", labelEs: "Oscuro", labelEn: "Dark", val: "dark" },
                                            { icon: "assets/claro logo.jpg", labelEs: "Claro", labelEn: "Light", val: "light" }
                                        ]

                                        Rectangle {
                                            width: 140; height: 40; radius: Theme.radiusMd
                                            color: (configManager && configManager.theme === modelData.val)
                                                   ? (Theme.activeTheme === "dark" ? Qt.rgba(0.12, 0.66, 1.0, 0.22) : Qt.rgba(0.12, 0.66, 1.0, 0.15))
                                                   : Theme.bgElevated
                                            border.color: (configManager && configManager.theme === modelData.val) ? Theme.accentPrimary : Theme.borderSubtle
                                            border.width: (configManager && configManager.theme === modelData.val) ? 2 : 1

                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 8
                                                Item {
                                                    width: 20; height: 20
                                                    Image {
                                                        anchors.fill: parent
                                                        source: modelData.icon
                                                        fillMode: Image.PreserveAspectFit
                                                        smooth: true
                                                    }
                                                }
                                                Text {
                                                    text: isEnglish ? modelData.labelEn : modelData.labelEs
                                                    font.pixelSize: 13
                                                    font.bold: configManager && configManager.theme === modelData.val
                                                    color: (configManager && configManager.theme === modelData.val) ? Theme.accentPrimary : Theme.textPrimary
                                                }
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (configManager) configManager.theme = modelData.val
                                                }
                                            }
                                        }
                                    }
                                }

                                // Color de acento
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 8
                                    Text {
                                        text: isEnglish ? "Accent Color:" : "Color de Acento Principal:"
                                        font.pixelSize: 13; color: Theme.textSecondary
                                    }
                                    RowLayout {
                                        spacing: 10
                                        Repeater {
                                            model: ["#1FA8FF","#10B981","#8B5CF6","#EF4444","#F59E0B","#06B6D4","#F97316","#EC4899"]
                                            Rectangle {
                                                width: 36; height: 36; radius: 18; color: modelData
                                                border.color: (configManager && configManager.accentColor.toUpperCase() === modelData) ? "#FFFFFF" : "transparent"
                                                border.width: 2.5
                                                Text {
                                                    anchors.centerIn: parent; text: "✓"; font.bold: true; color: "#FFF"
                                                    visible: configManager && configManager.accentColor.toUpperCase() === modelData
                                                }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (configManager) configManager.accentColor = modelData
                                                    }
                                                }
                                            }
                                        }
                                        TextField {
                                            Layout.preferredWidth: 110; height: 36
                                            text: configManager ? configManager.accentColor : ""
                                            font.pixelSize: 12; color: Theme.textPrimary
                                            background: Rectangle { radius: Theme.radiusSm; color: Theme.bgInput; border.color: Theme.borderSubtle }
                                            onEditingFinished: {
                                                if (text.startsWith("#") && (text.length === 7 || text.length === 4)) {
                                                    if (configManager) configManager.accentColor = text
                                                }
                                            }
                                        }
                                    }
                                }

                                // Slider de fuente
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 8
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: isEnglish ? "Base Font Size:" : "Tamaño de Fuente Base:"; font.pixelSize: 13; color: Theme.textSecondary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: (configManager ? configManager.fontSize : 14) + " pt"; font.pixelSize: 14; font.bold: true; color: Theme.accentPrimary }
                                    }
                                    Slider {
                                        Layout.fillWidth: true; from: 10; to: 24; stepSize: 1
                                        value: configManager ? configManager.fontSize : 14
                                        onMoved: {
                                            if (configManager) configManager.fontSize = value
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true; height: 50; radius: Theme.radiusMd; color: Theme.bgInput; border.color: Theme.borderSubtle
                                        Text {
                                            anchors.centerIn: parent; width: parent.width - 24
                                            text: isEnglish ? "Live Preview: The quick brown fox jumps over the lazy dog. 1234567890" : "Vista Previa: El pingüino comió ñandú en España — 1234567890 (UTF-8)"
                                            font.pixelSize: configManager ? configManager.fontSize : 14; color: Theme.textPrimary
                                            elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Idioma y opciones
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: optCol.implicitHeight + 36
                            radius: Theme.radiusLg
                            color: Theme.bgSurface
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                id: optCol
                                anchors.fill: parent; anchors.margins: 20; spacing: 16
                                Text {
                                    text: isEnglish ? "Language & Automation" : "Idioma y Automatización"
                                    font.pixelSize: 15; font.bold: true; color: Theme.textPrimary
                                }
                                RowLayout {
                                    Layout.fillWidth: true; spacing: 20
                                    Text { text: isEnglish ? "Interface Language:" : "Idioma de la Interfaz:"; font.pixelSize: 13; color: Theme.textSecondary }
                                    ComboBox {
                                        id: langSelector
                                        model: ["Español (es)", "English (en)"]
                                        currentIndex: (configManager && configManager.language === "en") ? 1 : 0
                                        onActivated: {
                                            if (configManager) {
                                                configManager.language = (currentIndex === 1 ? "en" : "es")
                                            }
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    RowLayout {
                                        spacing: 8
                                        CheckBox {
                                            id: autoSaveCheck
                                            checked: configManager ? configManager.autoSave : false
                                            onToggled: {
                                                if (configManager) configManager.autoSave = checked
                                            }
                                        }
                                        Text {
                                            text: isEnglish ? "Auto-Save (Auto-Commit on change)" : "Guardado Automático (Auto-Commit)"
                                            font.pixelSize: 13; color: Theme.textPrimary
                                        }
                                    }
                                }
                            }
                        }

                        // Botones de acción
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            NexusButton {
                                text: isEnglish ? "↺  Restore Factory Defaults" : "↺  Restablecer Valores de Fábrica"
                                variant: "danger"
                                onClicked: configManager.reset_to_defaults()
                            }
                            Item { Layout.fillWidth: true }
                            NexusButton {
                                text: isEnglish ? "💾  Save Changes (Safe-Write)" : "💾  Guardar Cambios (Safe-Write)"
                                variant: "primary"
                                implicitWidth: 260
                                onClicked: {
                                    if (configManager) {
                                        configManager.username = txtUsername.text
                                        configManager.save_configuration()
                                    }
                                }
                            }
                        }
                    }
                }

                // ===========================================================
                // VISTA 2: GESTOR Y EDITOR DE DOCUMENTOS Y ARCHIVOS
                // ===========================================================
                Item {
                    id: fileManagerView
                    property string selectedRelPath: "config.json"
                    property bool isEditing: false

                    // Modelo reactivo de lista nativa QML
                    ListModel {
                        id: filesListModel
                    }

                    Component.onCompleted: refreshFiles("config.json")

                    function refreshFiles(targetToSelect) {
                        if (!configManager) return;
                        filesListModel.clear();
                        var items = configManager.listConfigFiles();
                        var target = targetToSelect ? targetToSelect : selectedRelPath;
                        var foundTarget = false;

                        for (var i = 0; i < items.length; i++) {
                            filesListModel.append(items[i]);
                            if (items[i].rel_path === target) {
                                foundTarget = true;
                            }
                        }

                        if (foundTarget) {
                            selectedRelPath = target;
                        } else if (items.length > 0) {
                            selectedRelPath = items[0].rel_path;
                        } else {
                            selectedRelPath = "config.json";
                        }

                        loadFileContent(selectedRelPath);
                    }

                    function loadFileContent(path) {
                        selectedRelPath = path;
                        if (configManager) {
                            fileEditor.text = configManager.readConfigFile(path);
                        }
                    }

                    Connections {
                        target: configManager
                        function onFilesChanged() {
                            fileManagerView.refreshFiles(fileManagerView.selectedRelPath);
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 14

                        // Header Bar
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: isEnglish ? "Document & Configuration File Manager" : "Gestor y Editor de Documentos y Archivos"
                                    font.pixelSize: 20; font.bold: true; color: Theme.textPrimary
                                }
                                Text {
                                    text: isEnglish ? "Explore, read, create, edit and import configuration files directly in data/ directory." : "Explora, lee, crea, edita e importa archivos de configuración y datos en la carpeta data/."
                                    font.pixelSize: 12; color: Theme.textSecondary
                                }
                            }
                            Item { Layout.fillWidth: true }
                            NexusButton {
                                text: isEnglish ? "Import File..." : "Importar Archivo..."
                                variant: "secondary"
                                onClicked: configManager.open_file_import_dialog()
                            }
                            NexusButton {
                                text: isEnglish ? "+ New Document" : "+ Nuevo Documento"
                                variant: "secondary"
                                onClicked: {
                                    txtNewFileName.text = "nuevo_documento_" + (filesListModel.count + 1) + ".json"
                                    newFileDialog.open()
                                }
                            }
                            NexusButton {
                                text: isEnglish ? "Refresh" : "Actualizar"
                                variant: "secondary"
                                onClicked: refreshFiles(selectedRelPath)
                            }
                        }

                        // Banner interactivo de ayuda rápida
                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: Theme.radiusMd
                            color: Theme.activeTheme === "dark" ? Qt.rgba(0.12, 0.66, 1.0, 0.10) : Qt.rgba(0.12, 0.66, 1.0, 0.08)
                            border.color: Qt.rgba(0.12, 0.66, 1.0, 0.25)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 14

                                Text {
                                    text: isEnglish
                                          ? "💡 Guide: 1. Click a file to read.  •  2. Edit text in the editor.  •  3. Click 'Save File'.  •  4. '+ New Document' creates immediately."
                                          : "💡 Guía: 1. Clic en un archivo para leer.  •  2. Edita en el visor.  •  3. Pulsa 'Guardar Archivo'.  •  4. '+ Nuevo Documento' aparece al instante."
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Theme.accentPrimary
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // Split View: Files List (Left) + Integrated Editor (Right)
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 16

                            // Files List Card
                            Rectangle {
                                Layout.preferredWidth: 320
                                Layout.fillHeight: true
                                radius: Theme.radiusLg
                                color: Theme.bgSurface
                                border.color: Theme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: isEnglish ? "Files in data/" : "Archivos en data/"
                                            font.pixelSize: 13; font.bold: true; color: Theme.textPrimary
                                        }
                                        Item { Layout.fillWidth: true }
                                        Rectangle {
                                            width: 24; height: 18; radius: 9
                                            color: Theme.bgElevated
                                            Text {
                                                anchors.centerIn: parent
                                                text: filesListModel.count
                                                font.pixelSize: 10; font.bold: true; color: Theme.textSecondary
                                            }
                                        }
                                    }

                                    ListView {
                                        id: fileListView
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        spacing: 6
                                        model: filesListModel

                                        delegate: Rectangle {
                                            id: fileItemDelegate
                                            width: fileListView.width
                                            height: 52
                                            radius: Theme.radiusSm
                                            color: fileManagerView.selectedRelPath === model.rel_path
                                                   ? Qt.rgba(0.12, 0.66, 1.0, 0.18)
                                                   : (rowHoverMa.containsMouse ? Theme.bgElevated : Theme.bgInput)
                                            border.color: fileManagerView.selectedRelPath === model.rel_path
                                                          ? Theme.accentPrimary
                                                          : Theme.borderSubtle
                                            border.width: 1

                                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 8
                                                spacing: 8

                                                // ── Zona interactiva de selección del documento ──
                                                Item {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    MouseArea {
                                                        id: rowHoverMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            fileManagerView.loadFileContent(model.rel_path)
                                                        }
                                                    }

                                                    RowLayout {
                                                        anchors.fill: parent
                                                        spacing: 10

                                                        Item {
                                                            width: 20; height: 20
                                                            Image {
                                                                anchors.fill: parent
                                                                fillMode: Image.PreserveAspectFit
                                                                smooth: true
                                                                source: model.name.endsWith(".json") ? "assets/json logo.jpg"
                                                                      : model.name.endsWith(".bak") ? "assets/bak logo.jpg"
                                                                      : "assets/png logo.jpg"
                                                            }
                                                        }

                                                        ColumnLayout {
                                                            Layout.fillWidth: true
                                                            spacing: 1
                                                            Text {
                                                                text: model.name
                                                                font.pixelSize: 12
                                                                font.bold: fileManagerView.selectedRelPath === model.rel_path
                                                                color: Theme.textPrimary
                                                                elide: Text.ElideRight
                                                                Layout.fillWidth: true
                                                            }
                                                            Text {
                                                                text: model.size + " • " + model.type
                                                                font.pixelSize: 10
                                                                color: Theme.textSecondary
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── Botón de basurero interactivo y funcional ──
                                                Rectangle {
                                                    id: delTrashBtn
                                                    visible: model.name !== "config.json"
                                                    width: 32; height: 32; radius: 8
                                                    color: delBtnMa.containsMouse
                                                           ? Qt.rgba(0.94, 0.27, 0.27, 0.22)
                                                           : "transparent"
                                                    border.color: delBtnMa.containsMouse ? Theme.accentDanger : "transparent"
                                                    border.width: 1

                                                    Behavior on color { ColorAnimation { duration: 120 } }
                                                    Behavior on border.color { ColorAnimation { duration: 120 } }

                                                    // Ícono de basurero geométrico vectorial
                                                    Item {
                                                        anchors.centerIn: parent
                                                        width: 16; height: 18

                                                        // Tapa del basurero con rotación reactiva al hover
                                                        Item {
                                                            id: trashLid
                                                            width: 16; height: 4
                                                            anchors.top: parent.top
                                                            transformOrigin: Item.TopLeft
                                                            rotation: delBtnMa.containsMouse ? -20 : 0
                                                            Behavior on rotation { NumberAnimation { duration: 150 } }

                                                            // Asa superior de la tapa
                                                            Rectangle {
                                                                width: 6; height: 2; radius: 1
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                anchors.bottom: parent.top
                                                                color: delBtnMa.containsMouse ? Theme.accentDanger : Theme.textSecondary
                                                            }
                                                            // Barra horizontal de la tapa
                                                            Rectangle {
                                                                anchors.fill: parent; radius: 1
                                                                color: delBtnMa.containsMouse ? Theme.accentDanger : Theme.textSecondary
                                                            }
                                                        }

                                                        // Cuerpo del basurero
                                                        Rectangle {
                                                            anchors.top: trashLid.bottom
                                                            anchors.topMargin: 2
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            width: 13; height: 12
                                                            radius: 2
                                                            color: "transparent"
                                                            border.color: delBtnMa.containsMouse ? Theme.accentDanger : Theme.textSecondary
                                                            border.width: 1.5

                                                            // Ranuras verticales
                                                            Row {
                                                                anchors.centerIn: parent
                                                                spacing: 2
                                                                Rectangle { width: 1; height: 6; color: delBtnMa.containsMouse ? Theme.accentDanger : Theme.textSecondary }
                                                                Rectangle { width: 1; height: 6; color: delBtnMa.containsMouse ? Theme.accentDanger : Theme.textSecondary }
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: delBtnMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            deleteConfirmDialog.pendingPath = model.rel_path
                                                            deleteConfirmDialog.open()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Integrated Editor Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: Theme.radiusLg
                                color: Theme.bgSurface
                                border.color: Theme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Rectangle {
                                            width: 8; height: 8; radius: 4
                                            color: Theme.accentPrimary
                                        }
                                        Text {
                                            text: (isEnglish ? "Editing: " : "Editando: ") + fileManagerView.selectedRelPath
                                            font.pixelSize: 13; font.bold: true; color: Theme.accentPrimary
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        NexusButton {
                                            text: isEnglish ? "Reload" : "Recargar"
                                            variant: "secondary"
                                            implicitHeight: 32
                                            onClicked: fileManagerView.loadFileContent(fileManagerView.selectedRelPath)
                                        }
                                        NexusButton {
                                            text: isEnglish ? "Save File" : "Guardar Archivo"
                                            variant: "primary"
                                            implicitHeight: 32
                                            onClicked: configManager.writeConfigFile(fileManagerView.selectedRelPath, fileEditor.text)
                                        }
                                    }

                                    // Editor Area
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: Theme.radiusMd
                                        color: Theme.bgInput
                                        border.color: Theme.borderSubtle
                                        clip: true

                                        ScrollView {
                                            anchors.fill: parent
                                            anchors.margins: 8

                                            TextArea {
                                                id: fileEditor
                                                font.family: "Consolas, Courier New, monospace"
                                                font.pixelSize: 12
                                                color: Theme.textPrimary
                                                wrapMode: Text.NoWrap
                                                selectByMouse: true
                                                background: Rectangle { color: "transparent" }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Dialog for New File
                    Dialog {
                        id: newFileDialog
                        title: isEnglish ? "Create New Configuration Document" : "Crear Nuevo Documento de Configuración"
                        modal: true
                        standardButtons: Dialog.Ok | Dialog.Cancel
                        anchors.centerIn: parent
                        width: 420

                        ColumnLayout {
                            spacing: 12
                            width: parent.width
                            Text {
                                text: isEnglish ? "Document filename (saved directly in data/):" : "Nombre del archivo (se creará de inmediato en data/):"
                                color: Theme.textPrimary; font.pixelSize: 12
                            }
                            TextField {
                                id: txtNewFileName
                                Layout.fillWidth: true
                                text: "nueva_configuracion.json"
                                font.pixelSize: 13
                                color: Theme.textPrimary
                                selectByMouse: true
                                background: Rectangle { radius: 6; color: Theme.bgInput; border.color: Theme.borderSubtle }
                            }
                            Text {
                                text: isEnglish ? "Tip: Can be .json or .txt. A template with default settings will be created." : "Consejo: Puede ser .json o .txt. Se creará con una plantilla inicial válida."
                                color: Theme.textSecondary; font.pixelSize: 10
                            }
                        }

                        onAccepted: {
                            var created = configManager.createNewConfigFile(txtNewFileName.text);
                            if (created && created.length > 0) {
                                fileManagerView.refreshFiles(created);
                            } else {
                                fileManagerView.refreshFiles(fileManagerView.selectedRelPath);
                            }
                        }
                    }

                    // Dialog for Delete Confirmation
                    Dialog {
                        id: deleteConfirmDialog
                        property string pendingPath: ""
                        title: isEnglish ? "Delete file?" : "¿Eliminar archivo?"
                        modal: true
                        standardButtons: Dialog.Yes | Dialog.No
                        anchors.centerIn: parent
                        width: 380
                        Text {
                            width: parent.width
                            wrapMode: Text.Wrap
                            color: Theme.textPrimary
                            text: (isEnglish ? "Are you sure you want to permanently delete: " : "¿Estás seguro de que deseas eliminar permanentemente: ") + deleteConfirmDialog.pendingPath + "?"
                        }
                        onAccepted: {
                            configManager.deleteConfigFile(pendingPath);
                            fileManagerView.refreshFiles("config.json");
                        }
                    }
                }


                // ===========================================================
                // VISTA 3: ASISTENTE NEXUS AI
                // ===========================================================
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24; spacing: 16

                        // Header
                        Rectangle {
                            Layout.fillWidth: true; height: 62; radius: Theme.radiusMd; color: Theme.bgSurface; border.color: Theme.borderSubtle
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 14; spacing: 14
                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: Qt.rgba(0.12, 0.66, 1.0, 0.18)
                                    Text { anchors.centerIn: parent; text: "🧠"; font.pixelSize: 16 }
                                }
                                ColumnLayout {
                                    spacing: 1
                                    Text {
                                        text: "NEXUS Core AI — " + (isEnglish ? "Interactive Assistant" : "Asistente Interactivo")
                                        font.pixelSize: 14; font.bold: true; color: Theme.textPrimary
                                    }
                                    Text {
                                        text: isEnglish ? "Zero-Cloud • 100% Offline • Natural Language & Diagnostic Help" : "Zero-Cloud • 100% Offline • Configuración y Ayuda Operativa en Lenguaje Natural"
                                        font.pixelSize: 11; color: Theme.textSecondary
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    height: 28; radius: 14; color: Qt.rgba(0.06, 0.72, 0.51, 0.15); border.color: Theme.accentSuccess
                                    width: aiModelLabel.implicitWidth + 24
                                    RowLayout {
                                        anchors.centerIn: parent; spacing: 6
                                        Rectangle { width: 6; height: 6; radius: 3; color: Theme.accentSuccess }
                                        Text { id: aiModelLabel; text: isEnglish ? "Local Engine Active" : "Motor Local Autónomo Activo"; font.pixelSize: 11; font.bold: true; color: Theme.accentSuccess }
                                    }
                                }
                            }
                        }

                        // Chat Messages
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            radius: Theme.radiusLg; color: Theme.bgSurface; border.color: Theme.borderSubtle; clip: true

                            ListView {
                                id: chatListView
                                anchors.fill: parent; anchors.margins: 16; spacing: 14
                                model: ListModel {
                                    id: chatModel
                                    Component.onCompleted: {
                                        append({
                                            sender: "ai",
                                            text: isEnglish
                                                  ? "Hello! I am **NEXUS Core AI**. I can assist you with system configuration, file management, time machine rollbacks, or system diagnostic audits."
                                                  : "¡Hola! Soy **NEXUS Core AI**. Puedo ayudarte a configurar el sistema en lenguaje natural, guiarte en el uso del editor de archivos, la máquina del tiempo o auditar los registros de diagnóstico.",
                                            actions: ""
                                        })
                                    }
                                }
                                delegate: Item {
                                    width: chatListView.width
                                    height: bubblCol.implicitHeight + 12
                                    ColumnLayout {
                                        id: bubblCol
                                        width: Math.min(parent.width * 0.8, 620)
                                        anchors.right: model.sender === "user" ? parent.right : undefined
                                        anchors.left: model.sender === "ai" ? parent.left : undefined
                                        spacing: 4
                                        Text {
                                            text: model.sender === "user" ? (isEnglish ? "You" : "Tú") : "NEXUS Core AI"
                                            font.pixelSize: 10; font.bold: true; color: Theme.textDisabled
                                            anchors.right: model.sender === "user" ? parent.right : undefined
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            implicitHeight: bubText.implicitHeight + 20; radius: Theme.radiusMd
                                            color: model.sender === "user" ? Theme.accentPrimary : Theme.bgElevated
                                            Text {
                                                id: bubText
                                                anchors.fill: parent; anchors.margins: 10
                                                text: model.text; font.pixelSize: 13; wrapMode: Text.Wrap
                                                textFormat: Text.MarkdownText
                                                color: model.sender === "user" ? "#FFFFFF" : Theme.textPrimary
                                            }
                                        }
                                        Rectangle {
                                            visible: model.actions !== ""; height: 22
                                            implicitWidth: actLabel.implicitWidth + 16; radius: 11
                                            color: Qt.rgba(0.06, 0.72, 0.51, 0.15); border.color: Theme.accentSuccess
                                            Text { id: actLabel; anchors.centerIn: parent; text: "⚙ " + model.actions; font.pixelSize: 10; font.bold: true; color: Theme.accentSuccess }
                                        }
                                    }
                                }
                                onCountChanged: Qt.callLater(positionViewAtEnd)
                            }
                        }

                        // Interactive Quick Suggestion Chips
                        RowLayout {
                            Layout.fillWidth: true; spacing: 8
                            Repeater {
                                model: [
                                    { textEs: "🌙 Modo oscuro y letra 16", textEn: "🌙 Dark mode & size 16" },
                                    { textEs: "📁 ¿Dónde edito y agrego archivos?", textEn: "📁 Where do I edit files?" },
                                    { textEs: "🔍 Diagnosticar logs del sistema", textEn: "🔍 Diagnose system logs" },
                                    { textEs: "🕰️ ¿Cómo uso la Máquina del Tiempo?", textEn: "🕰️ How does Time Machine work?" }
                                ]
                                Rectangle {
                                    implicitWidth: chipTxt.implicitWidth + 20; height: 32; radius: 16
                                    color: Theme.bgElevated; border.color: Theme.borderSubtle
                                    Text { id: chipTxt; anchors.centerIn: parent; text: isEnglish ? modelData.textEn : modelData.textEs; font.pixelSize: 11; color: Theme.textPrimary }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: aiAgent.send_user_prompt(isEnglish ? modelData.textEn : modelData.textEs)
                                    }
                                }
                            }
                        }

                        // Chat Input
                        Rectangle {
                            Layout.fillWidth: true; height: 52; radius: Theme.radiusMd; color: Theme.bgSurface; border.color: Theme.borderSubtle
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 6; spacing: 10
                                TextField {
                                    id: chatInput; Layout.fillWidth: true; font.pixelSize: 13; color: Theme.textPrimary
                                    placeholderText: isEnglish ? "Ask a question or request a change (e.g. 'switch to dark mode and size 18')..." : "Haz una pregunta o pide un cambio (ej. 'pon tema claro, letra 16 y acento verde')..."
                                    background: Rectangle { color: "transparent" }
                                    onAccepted: { if (text.trim() !== "") { aiAgent.send_user_prompt(text); text = "" } }
                                }
                                NexusButton {
                                    text: isEnglish ? "Send" : "Enviar"
                                    variant: "primary"; implicitWidth: 80
                                    onClicked: { if (chatInput.text.trim() !== "") { aiAgent.send_user_prompt(chatInput.text); chatInput.text = "" } }
                                }
                            }
                        }
                    }

                    Connections {
                        target: aiAgent
                        function onMessageReceived(sender, text, actionSummary) { chatModel.append({ sender: sender, text: text, actions: actionSummary }) }
                        function onOllamaStatusChanged(available, modelName) { aiModelLabel.text = modelName }
                    }
                }

                // ===========================================================
                // VISTA 4: DIAGNÓSTICO, TELEMETRÍA Y MÁQUINA DEL TIEMPO
                // ===========================================================
                ScrollView {
                    contentWidth: width; clip: true

                    ColumnLayout {
                        width: Math.min(parent.width - 56, 960)
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Layout.topMargin: 24; Layout.bottomMargin: 36

                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 2
                                Text { text: isEnglish ? "System Diagnostics & Time Machine" : "Diagnóstico del Sistema y Máquina del Tiempo"; font.pixelSize: 22; font.bold: true; color: Theme.textPrimary }
                                Text { text: isEnglish ? "Real-time integrity telemetry, academic laboratory checklist, and certified snapshot restore." : "Telemetría de integridad en vivo, banco de pruebas de evaluación y restauración de versiones."; font.pixelSize: 13; color: Theme.textSecondary }
                            }
                            Item { Layout.fillWidth: true }
                            NexusButton { text: isEnglish ? "Refresh Telemetry" : "Actualizar Telemetría"; variant: "secondary"; onClicked: configManager.refresh_telemetry() }
                        }

                        // StatCards
                        GridLayout {
                            Layout.fillWidth: true; columns: 4; rowSpacing: 12; columnSpacing: 12
                            StatCard { title: "config.json"; valueText: (configManager && configManager.configExists) ? (isEnglish ? "Active" : "Activo") : (isEnglish ? "Missing" : "Ausente"); subText: configManager ? configManager.configSizeFormatted : ""; isOk: configManager && configManager.configExists }
                            StatCard { title: "config.bak"; valueText: (configManager && configManager.backupExists) ? (isEnglish ? "Available" : "Disponible") : (isEnglish ? "None" : "Sin crear"); subText: configManager ? configManager.backupSizeFormatted : ""; isOk: configManager && configManager.backupExists; isWarning: !(configManager && configManager.backupExists) }
                            StatCard { title: "config.tmp"; valueText: (configManager && configManager.tempExists) ? (isEnglish ? "Writing" : "En transacción") : (isEnglish ? "Clean" : "Purgado"); subText: isEnglish ? "No temp leaks" : "Sin residuos temporales"; isOk: !(configManager && configManager.tempExists) }
                            StatCard { title: isEnglish ? "Encoding" : "Codificación"; valueText: "UTF-8"; subText: configManager ? configManager.encodingStatus : ""; isOk: true }
                        }

                        // Máquina del Tiempo Card
                        Rectangle {
                            Layout.fillWidth: true
                            height: 280
                            radius: Theme.radiusLg
                            color: Theme.bgSurface
                            border.color: Theme.borderSubtle
                            border.width: 1

                            TimeMachinePanel {
                                anchors.fill: parent
                            }
                        }

                        // Banco de Pruebas
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: labCol.implicitHeight + 32
                            radius: Theme.radiusLg
                            color: Theme.bgSurface
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                id: labCol
                                anchors.fill: parent; anchors.margins: 20; spacing: 14

                                Text { text: isEnglish ? "Academic Evaluation Testbed — Lab No. 1" : "Banco de Pruebas de Evaluación — Laboratorio No. 1"; font.pixelSize: 15; font.bold: true; color: Theme.textPrimary }
                                Text { text: isEnglish ? "Execute the 4 empirical scenarios from the whitepaper to test self-healing and resilience:" : "Ejecuta los 4 escenarios de resiliencia del whitepaper para validar la auto-sanación:"; font.pixelSize: 12; color: Theme.textSecondary }

                                GridLayout {
                                    Layout.fillWidth: true; columns: 2; rowSpacing: 10; columnSpacing: 10
                                    NexusButton { Layout.fillWidth: true; text: isEnglish ? "1. Missing File Test (FileNotFoundError)" : "1. Probar Archivo Ausente (FileNotFoundError)"; variant: "secondary"; onClicked: { testResult.text = configManager.test_missing_file(); configManager.refresh_telemetry() } }
                                    NexusButton { Layout.fillWidth: true; text: isEnglish ? "2. Corrupt File Test (JSONDecodeError → .bak)" : "2. Probar Archivo Corrupto (JSONDecodeError → .bak)"; variant: "secondary"; onClicked: { testResult.text = configManager.test_corrupt_file(); configManager.refresh_telemetry() } }
                                    NexusButton { Layout.fillWidth: true; text: isEnglish ? "3. UTF-8 Test ('César Ñandú de España')" : "3. Probar Caracteres Especiales ('César Ñandú de España')"; variant: "secondary"; onClicked: testResult.text = configManager.test_special_chars_utf8() }
                                    NexusButton { Layout.fillWidth: true; text: isEnglish ? "4. Safe-Write Stress Test (3× ACID Commits)" : "4. Probar Escritura Segura Masiva (3× Safe-Write ACID)"; variant: "secondary"; onClicked: { testResult.text = configManager.test_safe_write_stress(); configManager.refresh_telemetry() } }
                                }

                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: testResult.implicitHeight + 16
                                    radius: Theme.radiusMd; color: Theme.bgInput; border.color: Theme.accentPrimary
                                    Text {
                                        id: testResult
                                        anchors.fill: parent; anchors.margins: 10
                                        text: isEnglish ? "Click any test button to inspect system reaction in real time." : "Haz clic en cualquiera de las pruebas para ver el resultado en vivo."
                                        font.pixelSize: 12; font.bold: true; color: Theme.accentPrimary; wrapMode: Text.Wrap
                                    }
                                }
                            }
                        }

                        // Terminal de Logs en vivo
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 260
                            radius: Theme.radiusLg; color: Theme.activeTheme === "dark" ? "#05070B" : "#1E293B"
                            border.color: Theme.borderSubtle

                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 14; spacing: 8
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: isEnglish ? "Live Log Stream (logs/app.log)" : "Terminal de Logs en Tiempo Real (logs/app.log)"; font.pixelSize: 13; font.bold: true; color: "#38BDF8" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "● Streaming"; font.pixelSize: 11; color: Theme.accentSuccess }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true; radius: Theme.radiusSm; color: Theme.activeTheme === "dark" ? "#08090E" : "#0F172A"; clip: true
                                    ListView {
                                        id: logListView
                                        anchors.fill: parent; anchors.margins: 8; spacing: 4
                                        model: ListModel { id: logListModel }
                                        delegate: Text {
                                            width: logListView.width
                                            text: model.logLine; font.family: "Consolas, Courier New, monospace"; font.pixelSize: 11; wrapMode: Text.Wrap
                                            color: model.logLine.indexOf("ERROR") !== -1 ? "#F87171"
                                                 : model.logLine.indexOf("WARNING") !== -1 ? "#FBBF24"
                                                 : model.logLine.indexOf("Commit") !== -1 ? "#60A5FA"
                                                  : model.logLine.indexOf("Auto-Sanación") !== -1 ? "#34D399"
                                                 : "#94A3B8"
                                        }
                                        onCountChanged: Qt.callLater(positionViewAtEnd)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Toast { id: appToast }
        }
        } 
    } 

    Connections {
        target: logEmitter
        function onNew_log(line) {
            logListModel.append({ logLine: line })
            if (logListModel.count > 300) logListModel.remove(0)
            dashLogModel.append({ line: line })
            if (dashLogModel.count > 10) dashLogModel.remove(0)
        }
    }
}
