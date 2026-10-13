//@ pragma UseQApplication
// QsMenuAnchor uses native platform menus and requires QApplication.

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    readonly property bool ready: Settings.ready && Theme.ready

    Variants {
        id: bars
        model: root.ready ? Quickshell.screens : []
        Bar {}
    }

    IpcHandler {
        target: "shell"
        function status(): string {
            if (!root.ready)
                return JSON.stringify({ready: false, settingsReady: Settings.ready, themeReady: Theme.ready});
            return JSON.stringify({
                ready: true,
                mode: Theme.mode,
                touch: Settings.touch,
                barHeight: Settings.barHeight,
                statusAvailable: DesktopState.statusAvailable,
                statusError: DesktopState.statusError,
                niriError: DesktopState.niriError,
                idleInhibited: DesktopState.inhibitIdle,
                volumeAvailable: DesktopState.volumeAvailable,
                brightnessAvailable: DesktopState.brightnessAvailable,
                keyboardEnabled: Settings.keyboardEnabled,
                keyboardActive: DesktopState.keyboardActive,
                outputs: bars.instances.map(bar => ({
                    name: bar.screen.name,
                    width: bar.width,
                    height: bar.height,
                    centerVisible: bar.centerVisible,
                    workspaceCount: bar.workspaces.length,
                    title: DesktopState.titleFor(bar.screen.name)
                }))
            });
        }
    }
}
