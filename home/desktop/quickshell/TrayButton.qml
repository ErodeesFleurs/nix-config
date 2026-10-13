import QtQuick
import QtQuick.Window
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: root
    required property var trayItem
    property bool showMenuButton: true
    spacing: 2
    implicitHeight: Settings.touch ? 44 : 32

    QsMenuAnchor {
        id: menuAnchor
        menu: root.trayItem.menu
        anchor.item: activateButton
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }
    ActionButton {
        id: activateButton
        description: root.trayItem.tooltipTitle || root.trayItem.title || root.trayItem.id
        highlighted: menuAnchor.visible
        onClicked: {
            if (root.trayItem.onlyMenu && root.trayItem.hasMenu)
                menuAnchor.open();
            else
                root.trayItem.activate();
        }
        onPressAndHold: {
            if (root.trayItem.hasMenu)
                menuAnchor.open();
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
            onTapped: {
                if (root.trayItem.hasMenu)
                    menuAnchor.open();
            }
        }
        onScrolled: steps => root.trayItem.scroll(steps * 120, false)
        scrollEnabled: true
        Item {
            anchors.centerIn: parent
            width: 20
            height: 20
            Image {
                id: glyphImage
                anchors.fill: parent
                source: Settings.trayIcons[root.trayItem.id] || root.trayItem.icon
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                fillMode: Image.PreserveAspectFit
                visible: false
                layer.enabled: true
            }
            Rectangle {
                id: ink
                anchors.fill: parent
                color: Theme.foreground
                visible: false
                layer.enabled: true
            }
            // Use alpha, not luminance: dark symbolic SVGs must stay readable.
            MultiEffect {
                anchors.fill: parent
                source: ink
                maskEnabled: true
                maskSource: glyphImage
            }
        }
    }
    ActionButton {
        visible: root.showMenuButton && root.trayItem.hasMenu && !root.trayItem.onlyMenu
        symbol: "󰅀"
        description: "Menu for " + (root.trayItem.title || root.trayItem.id)
        highlighted: menuAnchor.visible
        onClicked: menuAnchor.visible ? menuAnchor.close() : menuAnchor.open()
    }
}
