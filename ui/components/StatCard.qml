import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"

Rectangle {
    id: cardRoot
    Layout.fillWidth: true
    implicitHeight: 110
    radius: Theme.radiusMd

    property string title: "Métrica"
    property string valueText: "Estado"
    property string subText: "Detalles"
    property bool isOk: true
    property bool isWarning: false

    color: Theme.bgSurface
    border.color: Theme.borderSubtle
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: {
                    if (cardRoot.isWarning) return Theme.statusWarn;
                    return cardRoot.isOk ? Theme.accentSuccess : Theme.accentDanger;
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: 8
                    color: parent.color
                    opacity: 0.25
                    z: -1
                }
            }

            Text {
                text: cardRoot.title
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.textSecondary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Text {
            text: cardRoot.valueText
            font.pixelSize: 15
            font.bold: true
            color: Theme.textPrimary
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: cardRoot.subText
            font.pixelSize: 11
            color: {
                if (cardRoot.isWarning) return Theme.statusWarn;
                if (!cardRoot.isOk) return Theme.accentDanger;
                return Theme.textSecondary;
            }
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
