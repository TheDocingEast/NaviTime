import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    property string taskTitle: ""
    property string taskDesc: ""
    property string deadline: ""
    property int priority: 2
    property string assignee: ""
    property int taskId: -1

    signal cardClicked(int id)

    width: parent ? parent.width : 240
    height: cardCol.implicitHeight + 24
    color: cardArea.containsMouse ? "#3B4252" : "#343A47"
    border.color: {
        if (priority === 4) return "#BF616A"
        if (priority === 3) return "#D08770"
        if (priority === 2) return "#4C566A"
        return "#434C5E"
    }
    border.width: priority >= 3 ? 2 : 1
    radius: 0

    Behavior on color { ColorAnimation { duration: 100 } }

    // Priority indicator bar left
    Rectangle {
        width: 3
        height: parent.height
        anchors.left: parent.left
        color: {
            if (priority === 4) return "#BF616A"
            if (priority === 3) return "#D08770"
            if (priority === 2) return "#EBCB8B"
            return "#4C566A"
        }
    }

    ColumnLayout {
        id: cardCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        anchors.leftMargin: 16
        spacing: 6

        Text {
            text: taskTitle
            color: "#D8DEE9"
            font.family: "Monaspace Krypton"
            font.pixelSize: 13
            font.weight: Font.Medium
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Text {
            text: taskDesc
            color: "#4C566A"
            font.family: "Monaspace Krypton"
            font.pixelSize: 11
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            visible: taskDesc !== ""
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Row {
            spacing: 12
            Layout.topMargin: 4

            Text {
                text: {
                    if (priority === 4) return "!! CRITICAL"
                    if (priority === 3) return "! high"
                    if (priority === 2) return "medium"
                    return "low"
                }
                color: {
                    if (priority === 4) return "#BF616A"
                    if (priority === 3) return "#D08770"
                    if (priority === 2) return "#EBCB8B"
                    return "#4C566A"
                }
                font.family: "Monaspace Krypton"
                font.pixelSize: 10
                font.letterSpacing: 1
            }

            Text {
                text: deadline !== "" ? "⏱ " + deadline : ""
                color: "#81A1C1"
                font.family: "Monaspace Krypton"
                font.pixelSize: 10
                visible: deadline !== ""
            }
        }

        Text {
            text: assignee !== "" ? "→ " + assignee : ""
            color: "#5E81AC"
            font.family: "Monaspace Krypton"
            font.pixelSize: 10
            visible: assignee !== ""
            Layout.bottomMargin: 4
        }
    }

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: card.cardClicked(taskId)
    }
}
