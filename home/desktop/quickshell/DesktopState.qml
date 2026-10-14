pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.UPower

Singleton {
    id: root

    property bool inhibitIdle: false
    property string niriError: ""
    property string statusError: ""
    property var _workspaces: []
    property var _windows: []
    property var _status: ({})
    property bool _statusReceived: false
    property var _pendingWorkspace: null
    property int _pendingBrightness: -1
    property string powerProfileError: ""
    property string _powerProfileStderr: ""

    readonly property bool statusAvailable: statusProcess.running && _statusReceived
    readonly property var cpuUsage: statusAvailable && typeof _status.cpuUsage === "number" ? _status.cpuUsage : null
    readonly property var memoryUsage: statusAvailable && typeof _status.memoryUsage === "number" ? _status.memoryUsage : null
    readonly property string networkName: statusAvailable ? (_status.networkName || "") : ""
    readonly property string networkAddress: statusAvailable ? (_status.networkAddress || "") : ""
    readonly property bool networkUp: statusAvailable && _status.networkUp === true
    readonly property string downloadRate: networkUp ? (_status.downloadRate || "") : ""
    readonly property string uploadRate: networkUp ? (_status.uploadRate || "") : ""
    readonly property bool brightnessAvailable: statusAvailable && _status.brightnessAvailable === true && !!_status.brightnessDevice
    readonly property real brightnessPercent: brightnessAvailable ? _status.brightnessPercent : 0
    readonly property bool keyboardActive: Settings.keyboardEnabled && statusAvailable && _status.keyboardActive === true

    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property bool volumeAvailable: !!audioSink && audioSink.ready && !!audioSink.audio
    readonly property real volume: volumeAvailable ? audioSink.audio.volume * 100 : 0
    readonly property bool muted: volumeAvailable && audioSink.audio.muted

    PwObjectTracker { objects: [root.audioSink] }

    function setVolume(percent) {
        if (volumeAvailable)
            audioSink.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
    }

    function toggleMute() {
        if (volumeAvailable)
            audioSink.audio.muted = !audioSink.audio.muted;
    }

    readonly property bool batteryAvailable: statusAvailable && _status.batteryAvailable === true
    readonly property real batteryPercent: batteryAvailable ? _status.batteryPercent : 0
    readonly property bool batteryCharging: batteryAvailable && _status.batteryCharging === true
    readonly property string batteryTime: batteryAvailable ? _status.batteryTime : ""

    // Never use the native singleton's default balanced value as proof of a service.
    // The existing status sampler probes availability; native D-Bus notifications
    // remain authoritative for selection, supported modes, degradation and holds.
    readonly property bool powerProfilesAvailable: statusAvailable && _status.powerProfilesAvailable === true
    readonly property bool powerProfilePending: powerProfileAction.running
    readonly property string powerProfilesError: statusAvailable ? (_status.powerProfilesError || "") : "Status helper unavailable"
    readonly property string powerProfile: powerProfilesAvailable ? powerProfileName(PowerProfiles.profile) : ""
    readonly property bool hasPerformanceProfile: powerProfilesAvailable && PowerProfiles.hasPerformanceProfile
    readonly property string powerProfileDegradation: {
        if (!powerProfilesAvailable)
            return "";
        switch (PowerProfiles.degradationReason) {
        case PerformanceDegradationReason.LapDetected:
            return "性能受限：检测到设备放在膝上";
        case PerformanceDegradationReason.HighTemperature:
            return "性能受限：设备温度过高";
        default:
            return "";
        }
    }
    readonly property string powerProfileHolds: {
        if (!powerProfilesAvailable)
            return "";
        const holds = PowerProfiles.holds;
        const descriptions = [];
        for (let i = 0; i < holds.length; ++i) {
            const hold = holds[i];
            descriptions.push(powerProfileLabel(powerProfileName(hold.profile)) + " · "
                              + hold.applicationId + (hold.reason ? "：" + hold.reason : ""));
        }
        return descriptions.join("\n");
    }

    function powerProfileName(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver: return "power-saver";
        case PowerProfile.Balanced: return "balanced";
        case PowerProfile.Performance: return "performance";
        default: return "";
        }
    }

    function powerProfileLabel(profile) {
        switch (profile) {
        case "power-saver": return "省电";
        case "balanced": return "均衡";
        case "performance": return "性能";
        default: return "不可用";
        }
    }

    function setPowerProfile(profile) {
        if (!powerProfilesAvailable || powerProfilePending
                || !["power-saver", "balanced", "performance"].includes(profile)
                || (profile === "performance" && !hasPerformanceProfile))
            return;
        powerProfileError = "";
        _powerProfileStderr = "";
        // The CLI reports policy/service failures; never optimistically assign
        // PowerProfiles.profile or mark the requested mode as the active one.
        powerProfileAction.exec(Settings.commands.powerprofiles.concat(["set", profile]));
    }

    Process {
        id: powerProfileAction
        onExited: (code, status) => {
            if (code !== 0)
                root.powerProfileError = root._powerProfileStderr
                        || "切换电源模式失败 (" + code + ", " + status + ")";
        }
        stderr: SplitParser {
            onRead: data => {
                if (data.trim())
                    root._powerProfileStderr += (root._powerProfileStderr ? "\n" : "") + data.trim();
            }
        }
    }

    // Prefer a playing player; otherwise retain the first available paused player.
    readonly property var player: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length ? players[0] : null;
    }
    readonly property bool playerAvailable: !!player
    readonly property string mediaTitle: playerAvailable ? ((player.trackArtist ? player.trackArtist + " — " : "") + (player.trackTitle || player.identity)) : ""
    readonly property bool mediaPlaying: playerAvailable && player.isPlaying
    readonly property bool mediaCanPrevious: playerAvailable && player.canGoPrevious
    readonly property bool mediaCanNext: playerAvailable && player.canGoNext
    readonly property bool mediaCanToggle: playerAvailable && player.canTogglePlaying
    readonly property bool mediaVolumeAvailable: playerAvailable && player.canControl && player.volumeSupported

    function toggleMedia() {
        if (mediaCanToggle)
            player.togglePlaying();
    }

    function previousMedia() {
        if (mediaCanPrevious)
            player.previous();
    }

    function nextMedia() {
        if (mediaCanNext)
            player.next();
    }

    // Delta is in percentage points, matching the system volume controls.
    function changeMediaVolume(delta) {
        if (mediaVolumeAvailable)
            player.volume = Math.max(0, Math.min(1, player.volume + delta / 100));
    }

    function workspacesFor(screenName) {
        return _workspaces.filter(workspace => workspace.output === screenName)
                          .sort((left, right) => left.idx - right.idx);
    }

    function titleFor(screenName) {
        const workspace = _workspaces.find(item => item.output === screenName && item.is_active);
        if (!workspace || workspace.active_window_id === null)
            return "";
        const window = _windows.find(item => item.id === workspace.active_window_id && item.workspace_id === workspace.id);
        return window ? (window.title || window.app_id || "") : "";
    }

    function focusWorkspace(id) {
        if (!_workspaces.some(workspace => workspace.id === id))
            return;
        _pendingWorkspace = id;
        if (focusSocket.connected)
            sendWorkspaceFocus();
        else if (focusSocket.path)
            focusSocket.connected = true;
        else
            niriError = "NIRI_SOCKET is unavailable";
    }

    function sendWorkspaceFocus() {
        if (_pendingWorkspace === null)
            return;
        // Niri 26.04's CLI accepts indices/names, not stable IDs. The IPC accepts Id.
        focusSocket.write(JSON.stringify({Action: {FocusWorkspace: {reference: {Id: _pendingWorkspace}}}}) + "\n");
        focusSocket.flush();
        _pendingWorkspace = null;
    }

    Socket {
        id: focusSocket
        path: Quickshell.env("NIRI_SOCKET")
        onConnectedChanged: if (connected) root.sendWorkspaceFocus()
        onError: error => {
            root.niriError = "Niri focus socket error: " + error;
            console.error(root.niriError);
        }
        parser: SplitParser {
            onRead: data => {
                try {
                    const reply = JSON.parse(data);
                    if (reply.Err !== undefined) {
                        root.niriError = "Niri focus failed: " + reply.Err;
                        console.error(root.niriError);
                    }
                } catch (error) {
                    root.niriError = "Invalid Niri focus reply: " + error;
                    console.error(root.niriError);
                }
            }
        }
    }

    function applyNiriEvent(event) {
        if (event.WorkspacesChanged) {
            // Initial event-stream snapshots are authoritative and include removals/output moves.
            _workspaces = event.WorkspacesChanged.workspaces;
        } else if (event.WorkspaceActivated) {
            const change = event.WorkspaceActivated;
            const active = _workspaces.find(workspace => workspace.id === change.id);
            if (!active)
                return;
            _workspaces = _workspaces.map(workspace => Object.assign({}, workspace, {
                is_active: workspace.output === active.output ? workspace.id === change.id : workspace.is_active,
                is_focused: change.focused ? workspace.id === change.id : workspace.is_focused
            }));
        } else if (event.WorkspaceActiveWindowChanged) {
            const change = event.WorkspaceActiveWindowChanged;
            _workspaces = _workspaces.map(workspace => workspace.id === change.workspace_id
                ? Object.assign({}, workspace, {active_window_id: change.active_window_id}) : workspace);
        } else if (event.WorkspaceUrgencyChanged) {
            const change = event.WorkspaceUrgencyChanged;
            _workspaces = _workspaces.map(workspace => workspace.id === change.id
                ? Object.assign({}, workspace, {is_urgent: change.urgent}) : workspace);
        } else if (event.WindowsChanged) {
            _windows = event.WindowsChanged.windows;
        } else if (event.WindowOpenedOrChanged) {
            const window = event.WindowOpenedOrChanged.window;
            let windows = _windows.filter(item => item.id !== window.id);
            if (window.is_focused)
                windows = windows.map(item => Object.assign({}, item, {is_focused: false}));
            _windows = windows.concat([window]);
        } else if (event.WindowClosed) {
            const id = event.WindowClosed.id;
            _windows = _windows.filter(window => window.id !== id);
            _workspaces = _workspaces.map(workspace => workspace.active_window_id === id
                ? Object.assign({}, workspace, {active_window_id: null}) : workspace);
        } else if (event.WindowFocusChanged) {
            const id = event.WindowFocusChanged.id;
            _windows = _windows.map(window => Object.assign({}, window, {is_focused: window.id === id}));
        }
    }

    Process {
        id: niriEvents
        command: Settings.ready ? Settings.commands.niri.concat(["msg", "--json", "event-stream"]) : []
        running: Settings.ready
        onStarted: root.niriError = ""
        onRunningChanged: {
            if (!running && Settings.ready) {
                root._workspaces = [];
                root._windows = [];
                if (!root.niriError)
                    root.niriError = "Niri event stream stopped; reload Quickshell to reconnect";
            }
        }
        onExited: (code, status) => {
            root.niriError = "Niri event stream exited (" + code + ", " + status + "); reload Quickshell to reconnect";
            console.error(root.niriError);
        }
        stdout: SplitParser {
            onRead: data => {
                if (!data.trim())
                    return;
                try {
                    root.applyNiriEvent(JSON.parse(data));
                } catch (error) {
                    root.niriError = "Invalid Niri event: " + error;
                    console.error(root.niriError);
                    niriEvents.running = false;
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                root.niriError = data;
                console.error("Niri: " + data);
            }
        }
    }

    Process {
        id: statusProcess
        command: {
            if (!Settings.ready)
                return [];
            const args = ["--powerprofiles-command", JSON.stringify(Settings.commands.powerprofiles)];
            if (Settings.keyboardEnabled)
                args.push("--keyboard-unit", Settings.keyboardUnit,
                          "--systemctl-command", JSON.stringify(Settings.commands.systemctl));
            return Settings.commands.status.concat(args);
        }
        running: Settings.ready
        onStarted: root.statusError = ""
        onRunningChanged: {
            if (!running && Settings.ready) {
                root._statusReceived = false;
                root._status = {};
                if (!root.statusError)
                    root.statusError = "Status helper stopped; reload Quickshell to restart";
            }
        }
        onExited: (code, status) => {
            root.statusError = "Status helper exited (" + code + ", " + status + "); reload Quickshell to restart";
            console.error(root.statusError);
        }
        stdout: SplitParser {
            onRead: data => {
                if (!data.trim())
                    return;
                try {
                    const sample = JSON.parse(data);
                    if (!sample || typeof sample !== "object" || typeof sample.networkUp !== "boolean")
                        throw new Error("missing status fields");
                    root._status = sample;
                    root._statusReceived = true;
                    root.statusError = (sample.errors || []).join("; ");
                } catch (error) {
                    root._status = {};
                    root._statusReceived = false;
                    root.statusError = "Invalid status sample: " + error;
                    console.error(root.statusError);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                root.statusError = data;
                console.error("Status helper: " + data);
            }
        }
    }

    function setBrightness(percent) {
        if (!brightnessAvailable)
            return;
        _pendingBrightness = Math.round(Math.max(1, Math.min(100, percent)));
        // Coalesce slider movement; never kill an in-flight brightness write.
        brightnessDelay.restart();
    }

    function sendBrightness() {
        if (_pendingBrightness < 0 || brightnessAction.running || !brightnessAvailable)
            return;
        const percent = _pendingBrightness;
        _pendingBrightness = -1;
        brightnessAction.exec(Settings.commands.brightness.concat([
            "--machine-readable", "--class", "backlight", "--device", _status.brightnessDevice,
            "set", percent + "%"
        ]));
    }

    Timer {
        id: brightnessDelay
        interval: 100
        onTriggered: root.sendBrightness()
    }

    Process {
        id: brightnessAction
        onExited: (code, status) => {
            if (code !== 0) {
                root.statusError = "Brightness command exited (" + code + ", " + status + ")";
                console.error(root.statusError);
            }
            root.sendBrightness();
        }
        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split(",");
                if (fields.length >= 5 && fields[0] === root._status.brightnessDevice && /^\d+%$/.test(fields[3]))
                    root._status = Object.assign({}, root._status, {brightnessPercent: parseInt(fields[3], 10)});
            }
        }
        stderr: SplitParser {
            onRead: data => {
                root.statusError = "Brightness: " + data;
                console.error(root.statusError);
            }
        }
    }

    function toggleKeyboard() {
        if (Settings.keyboardEnabled && Settings.commands.keyboardToggle.length && !keyboardAction.running)
            keyboardAction.exec(Settings.commands.keyboardToggle);
    }

    Process {
        id: keyboardAction
        onExited: (code, status) => {
            if (code !== 0) {
                root.statusError = "Keyboard toggle exited (" + code + ", " + status + ")";
                console.error(root.statusError);
            }
        }
        stdout: SplitParser { onRead: data => console.log(data) }
        stderr: SplitParser {
            onRead: data => {
                root.statusError = "Keyboard: " + data;
                console.error(root.statusError);
            }
        }
    }
}
