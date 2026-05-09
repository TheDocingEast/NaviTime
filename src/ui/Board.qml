import QtQuick
import QtQuick.Layouts

Rectangle {
    anchors.fill: parent  // ← и тут
    color: "#1e1e2e"

    Component.onCompleted: backend.load_tasks(1)

    Row {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Repeater {
            model: ["In Order", "To Do", "Done"]

            Rectangle {
                width: 260
                height: parent.height
                color: "#313244"
                radius: 10

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: modelData
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Repeater {
                        model: backend.tasks.filter(t => t.status_id === index + 1)
                        TaskCard {
                            title: modelData.title
                            deadline: modelData.deadline
                            priority: modelData.priority
                        }
                    }
                }
            }
        }
    }
}
