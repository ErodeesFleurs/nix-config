pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var data: null
    readonly property bool ready: data !== null
    readonly property bool touch: ready && data.touch
    readonly property int barHeight: ready ? data.barHeight : 40
    readonly property string fontFamily: ready ? data.fontFamily : ""
    readonly property bool keyboardEnabled: ready && data.keyboardEnabled
    readonly property string keyboardUnit: ready ? data.keyboardUnit : ""
    readonly property string palettePath: ready ? data.palettePath : ""
    readonly property var commands: ready ? data.commands : ({})
    readonly property var trayIcons: ready ? data.trayIcons : ({})

    property FileView settingsFile: FileView {
        path: Quickshell.shellPath("settings.json")
        onLoaded: root.data = JSON.parse(text())
    }
}
