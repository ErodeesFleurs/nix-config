import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Settings.barHeight
    exclusiveZone: Settings.barHeight
    color: Theme.surface
    WlrLayershell.namespace: "quickshell-fleurs-bar"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    readonly property int sideWidth: Math.max(0, (width - clockButton.width) / 2 - 20)
    readonly property bool detailed: width >= (Settings.touch ? 1900 : 1600)
    readonly property bool showMedia: width >= (Settings.touch ? 2200 : 1900)
    readonly property bool showMetrics: width >= (Settings.touch ? 2600 : 2300)
    readonly property var workspaces: DesktopState.workspacesFor(screen.name)
    property alias centerVisible: center.visible
    onWorkspacesChanged: Qt.callLater(() => workspaceScroll.revealActive())

    function toggleCenter() { center.visible = !center.visible; }
    function percent(value) { return Math.round(value) + "%"; }

    IdleInhibitor { window: root; enabled: DesktopState.inhibitIdle }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    ControlCenter { id: center; barWindow: root }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.outline
        opacity: 0.3
    }
    RowLayout {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: root.sideWidth
        height: root.height - 4
        spacing: 8
        Flickable {
            id: workspaceScroll
            Layout.preferredWidth: Math.min(workspaceRow.implicitWidth, root.sideWidth * 0.65)
            Layout.maximumWidth: root.sideWidth
            Layout.fillHeight: true
            contentWidth: workspaceRow.implicitWidth
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            function revealActive() {
                for (let i = 0; i < workspaceRepeater.count; ++i) {
                    const button = workspaceRepeater.itemAt(i);
                    if (button && button.modelData.is_active) {
                        if (button.x < contentX)
                            contentX = button.x;
                        else if (button.x + button.width > contentX + width)
                            contentX = Math.min(contentWidth - width, button.x + button.width - width);
                        break;
                    }
                }
            }
            onWidthChanged: Qt.callLater(revealActive)
            Row {
                id: workspaceRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Repeater {
                    id: workspaceRepeater
                    model: root.workspaces
                    onItemAdded: Qt.callLater(workspaceScroll.revealActive)
                    ActionButton {
                        required property var modelData
                        label: String(modelData.idx)
                        description: "Workspace " + modelData.idx + (modelData.name ? " · " + modelData.name : "")
                        highlighted: modelData.is_active
                        foreground: modelData.is_focused ? Theme.primaryContainerForeground
                                    : modelData.is_active ? Theme.primary : Theme.foregroundVariant
                        minimumHeight: Settings.barHeight - 4
                        onClicked: DesktopState.focusWorkspace(modelData.id)
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            text: DesktopState.titleFor(root.screen.name)
            color: Theme.foregroundVariant
            font.family: Settings.fontFamily
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            clip: true
        }
    }
    ActionButton {
        id: clockButton
        anchors.centerIn: parent
        minimumHeight: Settings.barHeight - 4
        label: Qt.formatDateTime(clock.date, root.width < 800 ? "hh:mm" : "MMM d  hh:mm")
        description: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy") + " · Open Vicinae"
        highlighted: true
        onClicked: Quickshell.execDetached(Settings.commands.launcher)
    }
    Item {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: root.sideWidth
        height: root.height - 4
        clip: true
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            spacing: 4
            ActionButton {
                visible: root.detailed
                symbol: Theme.mode === "dark" ? "󰖔" : "󰖨"
                description: Theme.mode === "dark" ? "夜间模式 — 点击切换日间" : "日间模式 — 点击切换夜间"
                minimumHeight: Settings.barHeight - 4
                onClicked: Quickshell.execDetached(Settings.commands.darkman.concat(["toggle"]))
            }
            ActionButton {
                visible: root.detailed
                symbol: DesktopState.inhibitIdle ? "󰅶" : "󰾪"
                description: DesktopState.inhibitIdle ? "恢复自动锁屏和关屏" : "暂停自动锁屏和关屏"
                highlighted: DesktopState.inhibitIdle
                minimumHeight: Settings.barHeight - 4
                onClicked: DesktopState.inhibitIdle = !DesktopState.inhibitIdle
            }
            Flickable {
                id: trayViewport
                visible: SystemTray.items.values.length > 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: trayRow.implicitWidth
                Layout.minimumWidth: Settings.touch ? 44 : 32
                contentWidth: Math.max(width, trayRow.implicitWidth)
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                // Keep every registered item; overflow scrolls instead of slicing.
                Row {
                    id: trayRow
                    x: trayViewport.contentWidth - width
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Repeater {
                        model: SystemTray.items
                        TrayButton {
                            required property var modelData
                            trayItem: modelData
                            showMenuButton: false
                        }
                    }
                }
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
            }
            ActionButton {
                visible: root.width >= 900
                symbol: DesktopState.networkUp ? "󰤨" : "󰤮"
                label: root.detailed ? DesktopState.networkName : ""
                Layout.maximumWidth: 130
                description: (DesktopState.networkUp ? DesktopState.networkName + " · " + DesktopState.networkAddress : "Disconnected")
                             + "\n↓ " + DesktopState.downloadRate + "  ↑ " + DesktopState.uploadRate + "\nOpen impala Wi-Fi manager"
                minimumHeight: Settings.barHeight - 4
                onClicked: Quickshell.execDetached(Settings.commands.network)
            }
            ActionButton {
                symbol: DesktopState.muted ? "󰝟" : "󰕾"
                label: root.detailed && DesktopState.volumeAvailable ? root.percent(DesktopState.volume) : ""
                description: DesktopState.volumeAvailable ? (DesktopState.muted ? "Unmute" : "Mute") + " · " + root.percent(DesktopState.volume) + " · Scroll to adjust" : "No audio output device"
                enabled: DesktopState.volumeAvailable
                highlighted: DesktopState.muted
                minimumHeight: Settings.barHeight - 4
                onClicked: DesktopState.toggleMute()
                onScrolled: steps => DesktopState.setVolume(DesktopState.volume + steps * 5)
                scrollEnabled: true
            }
            ActionButton {
                visible: root.width >= 1100 && DesktopState.brightnessAvailable
                symbol: "󰃠"
                description: "Brightness " + root.percent(DesktopState.brightnessPercent) + " · Open controls or scroll to adjust"
                minimumHeight: Settings.barHeight - 4
                onClicked: root.toggleCenter()
                onScrolled: steps => DesktopState.setBrightness(DesktopState.brightnessPercent + steps * 5)
                scrollEnabled: DesktopState.brightnessAvailable
            }
            ActionButton {
                visible: root.showMetrics
                symbol: "󰍛"
                label: (DesktopState.cpuUsage === null ? "—" : root.percent(DesktopState.cpuUsage)) + " / "
                       + (DesktopState.memoryUsage === null ? "—" : root.percent(DesktopState.memoryUsage))
                description: "CPU / RAM · Open btop system monitor"
                minimumHeight: Settings.barHeight - 4
                onClicked: Quickshell.execDetached(Settings.commands.monitor)
            }
            ActionButton {
                visible: DesktopState.batteryAvailable
                symbol: DesktopState.batteryCharging ? "󰂄" : DesktopState.batteryPercent <= 10 ? "󰂎" : "󰁹"
                label: root.percent(DesktopState.batteryPercent)
                description: (DesktopState.batteryCharging ? "Charging" : "Battery") + " · " + root.percent(DesktopState.batteryPercent)
                             + (DesktopState.batteryTime ? " · " + DesktopState.batteryTime : "")
                foreground: !DesktopState.batteryCharging && DesktopState.batteryPercent <= 10 ? Theme.error
                            : !DesktopState.batteryCharging && DesktopState.batteryPercent <= 30 ? Theme.primary : Theme.foreground
                minimumHeight: Settings.barHeight - 4
                onClicked: root.toggleCenter()
            }
            ActionButton {
                visible: root.showMedia && DesktopState.playerAvailable
                symbol: DesktopState.mediaPlaying ? "󰏤" : "󰐊"
                label: DesktopState.mediaTitle
                Layout.preferredWidth: 140
                Layout.maximumWidth: 140
                description: DesktopState.mediaTitle + " · Play/pause" + (DesktopState.mediaVolumeAvailable ? " · Scroll to adjust player volume" : "")
                minimumHeight: Settings.barHeight - 4
                enabled: DesktopState.mediaCanToggle
                onClicked: DesktopState.toggleMedia()
                onScrolled: steps => DesktopState.changeMediaVolume(steps * 5)
                scrollEnabled: DesktopState.mediaVolumeAvailable
            }
            ActionButton {
                visible: Settings.keyboardEnabled
                symbol: "󰌌"
                description: DesktopState.keyboardActive ? "关闭屏幕键盘 (Mod+K)" : "打开屏幕键盘 (Mod+K)"
                highlighted: DesktopState.keyboardActive
                minimumHeight: Settings.barHeight - 4
                onClicked: DesktopState.toggleKeyboard()
            }
            ActionButton {
                symbol: "󰒓"
                description: "Open control center"
                highlighted: center.visible
                minimumHeight: Settings.barHeight - 4
                onClicked: root.toggleCenter()
            }
        }
    }
}
