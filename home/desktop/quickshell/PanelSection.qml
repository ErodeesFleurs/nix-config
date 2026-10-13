import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    default property alias content: body.data
    implicitHeight: column.implicitHeight + 24
    color: Theme.surfaceContainer
    radius: 18

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        Text {
            visible: root.title.length > 0
            text: root.title
            color: Theme.foregroundVariant
            font.family: Settings.fontFamily
            font.pixelSize: 11
            font.bold: true
            Layout.fillWidth: true
        }
        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 8
        }
    }
}
