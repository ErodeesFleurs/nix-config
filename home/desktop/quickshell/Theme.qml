pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var data: null
    readonly property bool ready: data !== null
    readonly property string mode: ready ? data.mode : ""
    readonly property color surface: ready ? data.surface : "transparent"
    readonly property color surfaceContainer: ready ? data.surfaceContainer : "transparent"
    readonly property color surfaceContainerHigh: ready ? data.surfaceContainerHigh : "transparent"
    // Foreground names avoid collisions with QML's on<Property> handlers.
    readonly property color foreground: ready ? data.onSurface : "transparent"
    readonly property color foregroundVariant: ready ? data.onSurfaceVariant : "transparent"
    readonly property color primary: ready ? data.primary : "transparent"
    readonly property color primaryContainer: ready ? data.primaryContainer : "transparent"
    readonly property color primaryContainerForeground: ready ? data.onPrimaryContainer : "transparent"
    readonly property color outline: ready ? data.outline : "transparent"
    readonly property color error: ready ? data.error : "transparent"

    function reload(): void {
        palette.reload();
    }

    property FileView palette: FileView {
        path: Settings.palettePath
        watchChanges: true
        onLoaded: root.data = JSON.parse(text())
        onFileChanged: reload()
    }

    // A current-directory symlink flip is not reliably reported by file watchers.
    // darkman calls this only after its atomic flip; no second theme authority.
    property IpcHandler appearance: IpcHandler {
        target: "appearance"
        function reload(): void { root.reload(); }
    }
}
