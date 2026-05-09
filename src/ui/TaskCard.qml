import QtQuick
import QtQuick.Layouts

Rectangle {
    property string title
    property string deadline
    property int priority

    width: 220
    height: 120
    radius: 8
    color: priority === 4 ? "#ff4444" : "#313244"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12

        Text {
            text: title
            color: "white"
            font.bold: true
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Text {
            text: deadline ?? "Без дедлайна"
            color: "#aaaaaa"
            font.pixelSize: 12
        }
    }
}
