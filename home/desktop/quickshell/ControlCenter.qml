import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

PopupWindow {
    id: root
    objectName: "controlCenter"
    required property var barWindow
    anchor.window: barWindow
    anchor.rect.x: Math.max(8, barWindow.width - implicitWidth - 8)
    anchor.rect.y: barWindow.height + 8
    implicitWidth: Math.min(Settings.touch ? 440 : 410, barWindow.width - 16)
    implicitHeight: Math.min(content.implicitHeight + 32, barWindow.screen.height - Settings.barHeight - 24)
    color: "transparent"
    grabFocus: true
    visible: false

    function launch(command) {
        root.visible = false;
        Quickshell.execDetached(command);
    }
    function percent(value) {
        return value === null || value === undefined ? "Unavailable" : Math.round(value) + "%";
    }
    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => closeButton.forceActiveFocus());
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Theme.surface
        border.width: 1
        border.color: Theme.outline
        clip: true
        Keys.priority: Keys.BeforeItem
        Keys.onEscapePressed: event => {
            root.visible = false;
            event.accepted = true;
        }
        Flickable {
            id: scroll
            objectName: "controlCenterScroll"
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: width
            contentHeight: content.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: content
                width: scroll.width
                spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Control center"
                        font.family: Settings.fontFamily
                        font.pixelSize: 19
                        font.bold: true
                        color: Theme.foreground
                        Layout.fillWidth: true
                    }
                    ActionButton {
                        symbol: "󰌾"
                        description: "Lock session"
                        onClicked: root.launch(Settings.commands.lock)
                    }
                    ActionButton {
                        id: closeButton
                        symbol: "󰅖"
                        description: "Close control center (Escape)"
                        onClicked: root.visible = false
                    }
                }
                PanelSection {
                    Layout.fillWidth: true
                    title: "SOUND"
                    RowLayout {
                        Layout.fillWidth: true
                        ActionButton {
                            symbol: DesktopState.muted ? "󰝟" : "󰕾"
                            label: DesktopState.muted ? "Muted" : root.percent(DesktopState.volume)
                            description: DesktopState.muted ? "Unmute output" : "Mute output"
                            enabled: DesktopState.volumeAvailable
                            highlighted: DesktopState.muted
                            onClicked: DesktopState.toggleMute()
                        }
                        Item { Layout.fillWidth: true }
                        ActionButton {
                            symbol: "󰒓"
                            label: "Mixer"
                            description: "Open audio mixer"
                            onClicked: root.launch(Settings.commands.audioMixer)
                        }
                    }
                    DeviceSlider {
                        Layout.fillWidth: true
                        enabled: DesktopState.volumeAvailable
                        value: DesktopState.volume
                        Accessible.name: "Output volume"
                        onMoved: DesktopState.setVolume(value)
                    }
                    Text {
                        visible: !DesktopState.volumeAvailable
                        text: "No audio output device"
                        color: Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                    }
                }
                PanelSection {
                    Layout.fillWidth: true
                    title: "BRIGHTNESS"
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰃠  Display"
                            color: Theme.foreground
                            font.family: Settings.fontFamily
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                        Text {
                            text: DesktopState.brightnessAvailable ? root.percent(DesktopState.brightnessPercent) : "No backlight device"
                            color: Theme.foregroundVariant
                            font.family: Settings.fontFamily
                            font.pixelSize: 12
                        }
                    }
                    DeviceSlider {
                        Layout.fillWidth: true
                        enabled: DesktopState.brightnessAvailable
                        from: 1
                        value: DesktopState.brightnessPercent
                        Accessible.name: "Display brightness"
                        onMoved: DesktopState.setBrightness(value)
                    }
                }
                PanelSection {
                    Layout.fillWidth: true
                    title: "NETWORK"
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: DesktopState.networkUp ? DesktopState.networkName : "Disconnected"
                            color: Theme.foreground
                            font.family: Settings.fontFamily
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        ActionButton {
                            label: "Wi-Fi"
                            symbol: "󰤨"
                            description: "Manage Wi-Fi with impala (iwd)"
                            onClicked: root.launch(Settings.commands.network)
                        }
                    }
                    Text {
                        text: DesktopState.networkAddress || "No IP address"
                        color: Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        text: "↓ " + DesktopState.downloadRate + "   ↑ " + DesktopState.uploadRate
                        color: Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
                PanelSection {
                    Layout.fillWidth: true
                    title: "MEDIA"
                    Text {
                        text: DesktopState.playerAvailable ? (DesktopState.mediaTitle || "Media player") : "No media player"
                        color: Theme.foreground
                        font.family: Settings.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        ActionButton {
                            symbol: "󰒮"
                            description: "Previous track"
                            enabled: DesktopState.playerAvailable && DesktopState.mediaCanPrevious
                            onClicked: DesktopState.previousMedia()
                        }
                        ActionButton {
                            symbol: DesktopState.mediaPlaying ? "󰏤" : "󰐊"
                            label: DesktopState.mediaPlaying ? "Pause" : "Play"
                            description: DesktopState.mediaPlaying ? "Pause media" : "Play media"
                            enabled: DesktopState.playerAvailable && DesktopState.mediaCanToggle
                            highlighted: DesktopState.mediaPlaying
                            Layout.fillWidth: true
                            onClicked: DesktopState.toggleMedia()
                            onScrolled: steps => DesktopState.changeMediaVolume(steps * 5)
                            scrollEnabled: DesktopState.mediaVolumeAvailable
                        }
                        ActionButton {
                            symbol: "󰒭"
                            description: "Next track"
                            enabled: DesktopState.playerAvailable && DesktopState.mediaCanNext
                            onClicked: DesktopState.nextMedia()
                        }
                        ActionButton {
                            symbol: "󰖁"
                            description: "Lower media player volume"
                            enabled: DesktopState.playerAvailable && DesktopState.mediaVolumeAvailable
                            onClicked: DesktopState.changeMediaVolume(-5)
                        }
                        ActionButton {
                            symbol: "󰕾"
                            description: "Raise media player volume"
                            enabled: DesktopState.playerAvailable && DesktopState.mediaVolumeAvailable
                            onClicked: DesktopState.changeMediaVolume(5)
                        }
                    }
                }
                PanelSection {
                    objectName: "powerProfilesPanel"
                    Layout.fillWidth: true
                    // System performance profiles do not control desktop idle inhibition.
                    title: "POWER"
                    Text {
                        objectName: "powerProfileStatus"
                        text: DesktopState.powerProfilesAvailable
                              ? "当前模式：" + DesktopState.powerProfileLabel(DesktopState.powerProfile)
                                + (DesktopState.powerProfilePending ? " · 正在切换…" : "")
                              : "电源模式服务不可用"
                        color: Theme.foreground
                        font.family: Settings.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ActionButton {
                            objectName: "powerSaverButton"
                            Layout.fillWidth: true
                            label: "省电"
                            description: "降低功耗，优先延长续航"
                            enabled: DesktopState.powerProfilesAvailable && !DesktopState.powerProfilePending
                            highlighted: DesktopState.powerProfile === "power-saver"
                            onClicked: DesktopState.setPowerProfile("power-saver")
                        }
                        ActionButton {
                            objectName: "balancedPowerButton"
                            Layout.fillWidth: true
                            label: "均衡"
                            description: "平衡性能与功耗"
                            enabled: DesktopState.powerProfilesAvailable && !DesktopState.powerProfilePending
                            highlighted: DesktopState.powerProfile === "balanced"
                            onClicked: DesktopState.setPowerProfile("balanced")
                        }
                        ActionButton {
                            objectName: "performancePowerButton"
                            Layout.fillWidth: true
                            label: "性能"
                            description: DesktopState.hasPerformanceProfile ? "优先性能，可能增加功耗和发热" : "此设备不支持性能模式"
                            enabled: DesktopState.hasPerformanceProfile && !DesktopState.powerProfilePending
                            highlighted: DesktopState.powerProfile === "performance"
                            onClicked: DesktopState.setPowerProfile("performance")
                        }
                    }
                    Text {
                        visible: DesktopState.powerProfilesAvailable && !DesktopState.hasPerformanceProfile
                        text: "此设备支持省电和均衡模式"
                        color: Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    Text {
                        visible: DesktopState.powerProfileDegradation.length > 0
                        text: DesktopState.powerProfileDegradation
                        color: Theme.primary
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    Text {
                        visible: DesktopState.powerProfileHolds.length > 0
                        text: "应用正在保持电源模式：\n" + DesktopState.powerProfileHolds
                        color: Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    Text {
                        objectName: "powerProfileError"
                        visible: text.length > 0
                        text: DesktopState.powerProfileError
                              || (!DesktopState.powerProfilesAvailable ? DesktopState.powerProfilesError : "")
                        color: Theme.error
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                }
                PanelSection {
                    Layout.fillWidth: true
                    title: "SYSTEM"
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "CPU " + root.percent(DesktopState.cpuUsage) + "\nRAM " + root.percent(DesktopState.memoryUsage)
                            color: Theme.foreground
                            font.family: Settings.fontFamily
                            font.pixelSize: 12
                            lineHeight: 1.5
                            Layout.fillWidth: true
                        }
                        ActionButton {
                            symbol: "󰍛"
                            label: "Monitor"
                            description: "Open btop system monitor"
                            onClicked: root.launch(Settings.commands.monitor)
                        }
                    }
                    Text {
                        visible: DesktopState.batteryAvailable
                        text: "󰁹 " + root.percent(DesktopState.batteryPercent) + (DesktopState.batteryCharging ? " · Charging" : " · Battery")
                              + (DesktopState.batteryTime ? " · " + DesktopState.batteryTime : "")
                        color: !DesktopState.batteryCharging && DesktopState.batteryPercent <= 10 ? Theme.error
                             : !DesktopState.batteryCharging && DesktopState.batteryPercent <= 30 ? Theme.primary : Theme.foregroundVariant
                        font.family: Settings.fontFamily
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                    }
                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        rowSpacing: 8
                        columnSpacing: 8
                        ActionButton {
                            Layout.fillWidth: true
                            symbol: Theme.mode === "dark" ? "󰖔" : "󰖨"
                            label: Theme.mode === "dark" ? "夜间模式" : "日间模式"
                            description: "通过 darkman 切换日夜主题"
                            onClicked: Quickshell.execDetached(Settings.commands.darkman.concat(["toggle"]))
                        }
                        ActionButton {
                            Layout.fillWidth: true
                            symbol: DesktopState.inhibitIdle ? "󰅶" : "󰾪"
                            label: DesktopState.inhibitIdle ? "保持唤醒" : "自动休眠"
                            description: DesktopState.inhibitIdle ? "恢复自动锁屏和关屏" : "暂停自动锁屏和关屏"
                            highlighted: DesktopState.inhibitIdle
                            onClicked: DesktopState.inhibitIdle = !DesktopState.inhibitIdle
                        }
                        ActionButton {
                            visible: Settings.keyboardEnabled
                            Layout.fillWidth: true
                            symbol: "󰌌"
                            label: DesktopState.keyboardActive ? "键盘已开启" : "屏幕键盘"
                            description: DesktopState.keyboardActive ? "关闭屏幕键盘 (Mod+K)" : "打开屏幕键盘 (Mod+K)"
                            highlighted: DesktopState.keyboardActive
                            onClicked: {
                                DesktopState.toggleKeyboard();
                                root.visible = false;
                            }
                        }
                    }
                }
                PanelSection {
                    visible: SystemTray.items.values.length > 0
                    Layout.fillWidth: true
                    title: "APPLICATIONS · ARROWS OPEN MENUS"
                    Flow {
                        Layout.fillWidth: true
                        spacing: 8
                        Repeater {
                            model: SystemTray.items
                            TrayButton { required property var modelData; trayItem: modelData }
                        }
                    }
                }
                Text {
                    visible: DesktopState.statusError.length > 0 || DesktopState.niriError.length > 0
                    text: [DesktopState.statusError, DesktopState.niriError].filter(message => message.length > 0).join("\n")
                    color: Theme.error
                    font.family: Settings.fontFamily
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
