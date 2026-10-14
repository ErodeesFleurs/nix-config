import QtQuick
import QtQml.Models
import QtQuick.Controls.Basic
import Quickshell

Menu {
    id: root
    property QsMenuHandle handle: null
    property bool loadChildren: false
    // Dynamic loading permits arbitrary application submenu depth without a
    // recursively instantiated QML type. Load children only while this menu is open.
    readonly property Component submenuComponent: Qt.createComponent("TrayMenu.qml")
    popupType: Popup.Window
    padding: 6
    margins: 8
    overlap: 4
    cascade: true
    font.family: Settings.fontFamily
    font.pixelSize: Settings.touch ? 14 : 13
    palette.windowText: Theme.foreground
    palette.window: Theme.surfaceContainer
    palette.highlight: Theme.primaryContainer
    palette.highlightedText: Theme.primaryContainerForeground
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    delegate: TrayMenuItem { }
    onAboutToShow: loadChildren = true
    onAboutToHide: currentIndex = -1
    // Qt finishes dismissing the cascade before its menu objects are released.
    onClosed: Qt.callLater(() => { if (!root.visible) root.loadChildren = false; })
    onHandleChanged: { if (!handle) dismiss(); }
    contentItem: ListView {
        id: menuList
        implicitHeight: contentHeight
        model: root.contentModel
        interactive: contentHeight > height
        clip: true
        currentIndex: -1
        // Guard selection synchronization during removal of selected submenu rows.
        Connections {
            target: root
            function onCurrentIndexChanged() {
                if (menuList.currentIndex !== root.currentIndex)
                    menuList.currentIndex = root.currentIndex;
            }
        }
        ScrollIndicator.vertical: ScrollIndicator {
            visible: size < 1
            contentItem: Rectangle { implicitWidth: 3; implicitHeight: 20; radius: 1.5; color: Theme.outline }
        }
    }

    background: Rectangle {
        implicitWidth: 240
        implicitHeight: 40
        color: Theme.surfaceContainer
        border.color: Theme.outline
        border.width: 1
        radius: 12
    }
    QsMenuOpener {
        id: opener
        menu: root.loadChildren ? root.handle : null
    }
    Component {
        id: itemComponent
        TrayMenuItem { }
    }
    Component {
        id: separatorComponent
        MenuSeparator {
            padding: 4
            contentItem: Rectangle {
                implicitWidth: 200
                implicitHeight: 1
                color: Theme.outline
                opacity: 0.4
            }
        }
    }
    Instantiator {
        model: opener.children
        delegate: QtObject {
            id: entry
            required property QsMenuEntry modelData
            required property int index
            property var item: null
            property bool submenu: false

            function release() {
                if (!item) return;
                if (submenu) root.removeMenu(item);
                else root.removeItem(item);
                item.destroy();
                item = null;
            }
            function rebuild() {
                release();
                submenu = !modelData.isSeparator && modelData.hasChildren;
                if (submenu) {
                    item = root.submenuComponent.createObject(root, {
                        handle: modelData,
                        title: Qt.binding(() => entry.modelData.text),
                        enabled: Qt.binding(() => entry.modelData.enabled)
                    });
                    item.icon.source = Qt.binding(() => entry.modelData.icon);
                    root.insertMenu(index, item);
                } else {
                    item = modelData.isSeparator
                         ? separatorComponent.createObject(root.contentItem)
                         : itemComponent.createObject(root.contentItem, { entry: modelData });
                    root.insertItem(index, item);
                }
            }
            property Connections shapeChanges: Connections {
                target: entry.modelData
                function onHasChildrenChanged() { entry.rebuild(); }
                function onIsSeparatorChanged() { entry.rebuild(); }
            }
            Component.onCompleted: rebuild()
            Component.onDestruction: release()
        }
    }
}
