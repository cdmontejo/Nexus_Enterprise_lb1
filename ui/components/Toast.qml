import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"

Item {
    id: toastRoot
    width: parent ? Math.min(parent.width - 40, 480) : 420
    height: contentColumn.implicitHeight + 24
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: visible ? 24 : -100

    property string toastType: "info" // "info", "success", "warning", "error"
    property string title: ""
    property string message: ""

    visible: opacity > 0
    opacity: 0

    Behavior on anchors.topMargin {
        NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    function show(type, t, m) {
        toastType = type;
        title = t;
        message = m;
        opacity = 1;
        anchors.topMargin = 24;
        hideTimer.restart();
    }

    function hide() {
        opacity = 0;
        anchors.topMargin = -100;
    }

    Timer {
        id: hideTimer
        interval: 4000
        onTriggered: toastRoot.hide()
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bgSurface
        border.color: {
            if (toastType === "success") return Theme.accentSuccess;
            if (toastType === "warning") return Theme.statusWarn;
            if (toastType === "error") return Theme.accentDanger;
            return Theme.accentPrimary;
        }
        border.width: 1.5

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 13
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.15)
            border.width: 2
            z: -1
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: {
                    if (toastType === "success") return Qt.rgba(0.06, 0.72, 0.51, 0.15);
                    if (toastType === "warning") return Qt.rgba(0.96, 0.62, 0.04, 0.15);
                    if (toastType === "error") return Qt.rgba(0.94, 0.27, 0.27, 0.15);
                    return Qt.rgba(0.12, 0.66, 1.0, 0.15);
                }

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (toastType === "success") return "✓";
                        if (toastType === "warning") return "⚠";
                        if (toastType === "error") return "✕";
                        return "ℹ";
                    }
                    font.bold: true
                    font.pixelSize: 18
                    color: {
                        if (toastType === "success") return Theme.accentSuccess;
                        if (toastType === "warning") return Theme.statusWarn;
                        if (toastType === "error") return Theme.accentDanger;
                        return Theme.accentPrimary;
                    }
                }
            }

            ColumnLayout {
                id: contentColumn
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: toastRoot.title
                    font.bold: true
                    font.pixelSize: 14
                    color: Theme.textPrimary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: toastRoot.message
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: closeMouse.containsMouse ? Theme.bgElevated : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: 16
                    color: Theme.textSecondary
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toastRoot.hide()
                }
            }
        }
    }
}
