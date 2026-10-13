import QtQuick
import QtQuick.Controls

Slider {
    id: root
    from: 0
    to: 100
    stepSize: 1
    implicitHeight: Settings.touch ? 44 : 36
    focusPolicy: Qt.StrongFocus
    opacity: enabled ? 1 : 0.4
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 8
        radius: 4
        color: Theme.surfaceContainerHigh
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: Theme.primary
        }
    }
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: Settings.touch ? 24 : 20
        height: width
        radius: width / 2
        color: Theme.primary
        border.width: root.visualFocus ? 3 : 2
        border.color: root.visualFocus ? Theme.foreground : Theme.surface
    }
}
