import QtQuick
import QtQuick.Controls.Basic
import Quickshell

MenuItem {
    id: root
    property QsMenuEntry entry: null
    readonly property bool radio: entry && entry.buttonType === QsMenuButtonType.RadioButton
    readonly property bool partial: entry && entry.checkState === Qt.PartiallyChecked

    checkable: entry && entry.buttonType !== QsMenuButtonType.None
    checked: entry && entry.checkState !== Qt.Unchecked
    icon.width: 18
    icon.height: 18
    font.family: Settings.fontFamily
    font.pixelSize: Settings.touch ? 14 : 13
    implicitHeight: Settings.touch ? 44 : 34
    leftPadding: 10
    rightPadding: 10
    spacing: 8
    opacity: enabled ? 1 : 0.45
    palette.windowText: highlighted ? Theme.primaryContainerForeground : Theme.foreground
    onTriggered: { if (entry) entry.triggered(); }

    // Submenu delegates inherit their QAction; only leaf entries override it.
    Binding {
        target: root
        property: "text"
        value: root.entry ? root.entry.text : ""
        when: root.entry !== null
    }
    Binding {
        target: root
        property: "enabled"
        value: !root.entry || root.entry.enabled
        when: root.entry !== null
    }
    Binding {
        target: root
        property: "icon.source"
        value: root.entry ? root.entry.icon : ""
        when: root.entry !== null
    }

    indicator: Item {
        implicitWidth: 16
        implicitHeight: 16
        x: root.mirrored ? root.width - width - root.rightPadding : root.leftPadding
        y: (root.height - height) / 2
        visible: root.checkable
        Rectangle {
            anchors.fill: parent
            radius: root.radio ? 8 : 3
            color: "transparent"
            border.width: 1
            border.color: root.palette.windowText
            Rectangle {
                anchors.centerIn: parent
                width: root.partial ? 8 : 6
                height: root.partial ? 2 : 6
                radius: root.radio ? 3 : 1
                color: root.palette.windowText
                visible: root.checked && (root.radio || root.partial)
            }
            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 13
                color: root.palette.windowText
                visible: root.checked && !root.radio && !root.partial
            }
        }
    }
    background: Rectangle {
        implicitWidth: 220
        implicitHeight: Settings.touch ? 44 : 34
        radius: 8
        color: root.highlighted || root.down ? Theme.primaryContainer : "transparent"
        border.width: root.visualFocus ? 1 : 0
        border.color: Theme.primary
    }
}
