import QtQuick 2.15
import QtQuick.Controls 2.15
import "../theme"

Button {
    id: control

    property string variant: "primary"
    property bool busy: false

    implicitWidth: Math.max(112, contentRow.implicitWidth + leftPadding + rightPadding)
    implicitHeight: 40
    leftPadding: 18
    rightPadding: 18
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true
    enabled: !busy

    font.pixelSize: 13
    font.weight: Font.DemiBold
    font.family: "Segoe UI, Inter, sans-serif"

    readonly property color fillIdle: {
        switch (variant) {
            case "primary":   return Theme.accentPrimary
            case "success":   return Theme.accentSuccess
            case "danger":    return Theme.accentDanger
            case "secondary": return Theme.bgElevated
            case "ghost":     return "transparent"
            default:          return Theme.accentPrimary
        }
    }

    readonly property color fillHover: {
        switch (variant) {
            case "primary":   return Theme.accentPrimaryHover
            case "success":   return Qt.lighter(Theme.accentSuccess, 1.15)
            case "danger":    return Qt.lighter(Theme.accentDanger, 1.15)
            case "secondary": return Theme.bgInput
            case "ghost":     return Theme.bgElevated
            default:          return Theme.accentPrimaryHover
        }
    }

    readonly property color fillPressed: {
        switch (variant) {
            case "primary":   return Theme.accentPrimaryPressed
            case "success":   return Qt.darker(Theme.accentSuccess, 1.2)
            case "danger":    return Qt.darker(Theme.accentDanger, 1.2)
            case "secondary": return Theme.bgSurface
            case "ghost":     return Theme.bgSurface
            default:          return Theme.accentPrimaryPressed
        }
    }

    readonly property color borderClr: {
        switch (variant) {
            case "secondary": return Theme.borderSubtle
            case "ghost":     return "transparent"
            default:          return "transparent"
        }
    }

    readonly property color textClr: {
        switch (variant) {
            case "primary":   return "#FFFFFF"
            case "success":   return "#0A0E14"
            case "danger":    return "#FFFFFF"
            case "secondary": return Theme.textPrimary
            case "ghost":     return Theme.textSecondary
            default:          return Theme.textPrimary
        }
    }

    background: Rectangle {
        radius: Theme.radiusMd
        color: control.down ? control.fillPressed
             : control.hovered ? control.fillHover
             : control.fillIdle
        border.width: (control.variant === "secondary") ? 1 : 0
        border.color: control.borderClr
        opacity: control.enabled ? 1.0 : 0.45

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    contentItem: Row {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent

        BusyIndicator {
            visible: control.busy
            running: control.busy
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.text
            color: control.textClr
            font: control.font
            anchors.verticalCenter: parent.verticalCenter
            visible: !control.busy
        }
    }
}
