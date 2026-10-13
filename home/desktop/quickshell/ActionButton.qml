import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Button {
    id: root
    property string symbol: ""
    property string label: ""
    property string description: label
    property bool scrollEnabled: false
    property color foreground: highlighted ? Theme.primaryContainerForeground : Theme.foreground
    property int minimumWidth: Settings.touch ? 44 : 32
    property int minimumHeight: Settings.touch ? 44 : 32
    signal scrolled(real steps)

    implicitWidth: Math.max(minimumWidth, contents.implicitWidth + 20)
    implicitHeight: minimumHeight
    padding: 8
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: description
    Accessible.role: Accessible.Button
    // A passive native popup can extend outside a layer bar without covering
    // its button or requesting Qt's mouse/keyboard grab.
    Timer {
        id: tooltipDelay
        property bool elapsed: false
        interval: 550
        running: root.hovered && !root.down && root.description.length > 0
        onRunningChanged: { if (running) elapsed = false; }
        onTriggered: elapsed = true
    }
    PopupWindow {
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        visible: root.hovered && !root.down && tooltipDelay.elapsed
        grabFocus: false
        implicitWidth: tooltipText.implicitWidth + 20
        implicitHeight: tooltipText.implicitHeight + 20
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.surfaceContainerHigh
            border.color: Theme.outline
            Text {
                id: tooltipText
                anchors.centerIn: parent
                text: root.description
                color: Theme.foreground
                font.family: Settings.fontFamily
                font.pixelSize: 12
            }
        }
    }
    opacity: enabled ? 1 : 0.45

    contentItem: Item {
        id: contents
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            width: Math.min(implicitWidth, parent.width)
            spacing: 6
            Text {
                visible: root.symbol.length > 0
                text: root.symbol
                color: root.foreground
                font.family: Settings.fontFamily
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                visible: root.label.length > 0
                text: root.label
                color: root.foreground
                font.family: Settings.fontFamily
                font.pixelSize: Settings.touch ? 13 : 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
    background: Rectangle {
        radius: height / 2
        color: root.down ? Theme.primaryContainer
             : root.highlighted ? Theme.primaryContainer
             : root.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainer
        border.width: root.visualFocus ? 2 : 0
        border.color: Theme.primary
        Behavior on color { ColorAnimation { duration: 100 } }
    }
    WheelHandler {
        enabled: root.enabled && root.scrollEnabled
        onWheel: event => {
            root.scrolled(event.angleDelta.y / 120);
            event.accepted = true;
        }
    }
}
