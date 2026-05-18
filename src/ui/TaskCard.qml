import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    property string taskTitle: ""
    property string taskDesc: ""
    property string deadline: ""
    property int priority: 2
    property string assignee: ""
    property string workspaceName: ""
    property int taskId: -1

    signal cardClicked(int id)

    // Drag поддержка
    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.keys: ["task"]

    // Сохраняем оригинальную позицию
    property int currentStatusId: 0
    property real origX: 0
    property real origY: 0

    width: 250
    height: cardCol.implicitHeight + 24
    color: dragArea.containsMouse ? "#3B4252" : "#343A47"
    border.color: {
        if (priority === 4) return "#BF616A"
        if (priority === 3) return "#D08770"
        if (priority === 2) return "#4C566A"
        return "#434C5E"
    }
    anchors.margins: 4
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

        Rectangle {
            visible: workspaceName !== ""
            width: wsTagText.implicitWidth + 12
            height: 18
            color: nord2
            border.color: nord3; border.width: 1

            Text {
                id: wsTagText
                anchors.centerIn: parent
                text: workspaceName.toUpperCase()
                color: nord9
                font.family: "Monaspace Krypton"
                font.pixelSize: 9
                font.letterSpacing: 1
            }
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
        id: dragArea
        anchors.fill: parent
        drag.target: card


        // onPressed: {
        //     card.origX = card.x
        //     card.origY = card.y
        //     card.Drag.active = true
        // }

        onReleased: {
            var result = card.Drag.drop()
            // Всегда возвращаем карточку на место — backend и Repeater сами обновят UI
            card.x = card.origX
            card.y = card.origY
            card.Drag.active = false
        }

        onClicked: card.cardClicked(taskId)  // клик без drag
    }

    states: State {
        when: dragArea.drag.active
        ParentChange {
            target: card
            parent: root  // ← root это Board.qml Rectangle
        }
        PropertyChanges {
            target: card
            z: 999
            opacity: 0.85
        }
    }
}
