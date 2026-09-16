import QtQuick 2.15
import Qt5Compat.GraphicalEffects 1.15
import "../theme"

Item {
    id: root

    property string source: ""
    property string fallbackInitials: "U"
    property real radius: width / 2
    property color borderColor: "transparent"
    property real borderWidth: 0
    property color backgroundColor: Theme.bgBase

    Rectangle {
        id: bgCircle
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.color: root.borderColor
        border.width: root.borderWidth
    }

    Text {
        anchors.centerIn: parent
        text: root.fallbackInitials
        font.pixelSize: Math.max(10, Math.floor(root.width * 0.38))
        font.bold: true
        color: Theme.accentPrimary
        visible: root.source === "" || imgSource.status !== Image.Ready
    }

    Image {
        id: imgSource
        anchors.fill: parent
        anchors.margins: root.borderWidth
        source: root.source
        fillMode: Image.PreserveAspectCrop
        cache: false
        smooth: true
        visible: false
    }

    Rectangle {
        id: maskRect
        anchors.fill: imgSource
        radius: Math.max(0, root.radius - root.borderWidth)
        visible: false
    }

    OpacityMask {
        anchors.fill: imgSource
        source: imgSource
        maskSource: maskRect
        visible: root.source !== "" && imgSource.status === Image.Ready
    }
}
