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
