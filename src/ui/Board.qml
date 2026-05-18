import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#2E3440"

    readonly property color nord0:  "#2E3440"
    readonly property color nord1:  "#3B4252"
    readonly property color nord2:  "#434C5E"
    readonly property color nord3:  "#4C566A"
    readonly property color nord4:  "#D8DEE9"
    readonly property color nord8:  "#88C0D0"
    readonly property color nord9:  "#81A1C1"
    readonly property color nord10: "#5E81AC"
    readonly property color nord11: "#BF616A"
    readonly property color nord13: "#EBCB8B"
    readonly property color nord14: "#A3BE8C"

    property string currentUser: backend.currentUser
    property string currentRole: backend.currentRole
    property int currentWorkspace: backend.currentWorkspaceId
    property string currentWorkspaceName: backend.currentWorkspaceName
    property int selectedPriority: 2

    Component.onCompleted: {
        backend.load_tasks(currentWorkspace)
        backend.load_statuses(currentWorkspace)
        if (currentRole === "manager") {
            backend.load_workspaces()   // нужны для фильтра
        }
    }

    // ── Top bar ──────────────────────────────────────────────
    Rectangle {
        id: topBar
        width: parent.width
        height: 48
        color: nord1
        anchors.top: parent.top
        z: 10

        Rectangle { width: parent.width; height: 2; color: nord8; anchors.top: parent.top }
        Rectangle { width: parent.width; height: 1; color: nord2; anchors.bottom: parent.bottom }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Text {
                text: "//"
                color: nord8
                font.family: "Monaspace Krypton"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "KANBAN"
                color: nord4
                font.family: "Monaspace Krypton"
                font.pixelSize: 14
                font.weight: Font.Bold
                font.letterSpacing: 2
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                width: 1
                height: 20
                color: nord2
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: currentWorkspaceName.toUpperCase()
                color: nord9
                font.family: "Monaspace Krypton"
                font.pixelSize: 12
                font.letterSpacing: 1
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Rectangle {
                visible: backend.hotTask !== null
                height: 28
                width: hotTaskRow.implicitWidth + 20
                color: "#3B2A2A"
                border.color: nord11
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter


                Row {
                    id: hotTaskRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "!!"; color: nord11; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                    Text {
                        text: backend.hotTask ? backend.hotTask.title : ""
                        color: nord11
                        font.family: "Monaspace Krypton"
                        font.pixelSize: 11
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 200)
                    }
                }
            }


            Rectangle { width: 1; height: topBar.height - 14; color: nord2; anchors.verticalCenter: parent.verticalCenter }

            Text {
                text: currentRole === "manager" ? "[manager]" : "[employee]"
                color: currentRole === "manager" ? nord13 : nord9
                font.family: "Monaspace Krypton"
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: currentUser;
                color: nord4;
                font.family: "Monaspace Krypton";
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                visible: currentRole === "manager"
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                // Кнопка "ALL"
                Rectangle {
                    width: 42; height: 28
                    color: backend.workspaceFilterId === -1 ? nord9 : "transparent"
                    border.color: nord3; border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }

                    Text {
                        anchors.centerIn: parent
                        text: "ALL"
                        color: backend.workspaceFilterId === -1 ? nord0 : nord4
                        font.family: "Monaspace Krypton"; font.pixelSize: 10
                        font.letterSpacing: 1
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: backend.setWorkspaceFilter(-1)
                    }
                }

                Repeater {
                    model: backend.workspaces

                    Rectangle {
                        width: wsLabel.implicitWidth + 16; height: 28
                        color: backend.workspaceFilterId === modelData.workspace_id ? nord9 : "transparent"
                        border.color: nord3
                        border.width: 1
                        // Левая граница убирает дублирование — соседние кнопки смыкаются
                        Rectangle { width: 1; height: parent.height; color: nord3 }
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            id: wsLabel
                            anchors.centerIn: parent
                            text: modelData.name.toUpperCase()
                            color: backend.workspaceFilterId === modelData.workspace_id ? nord0 : nord4
                            font.family: "Monaspace Krypton"; font.pixelSize: 10
                            font.letterSpacing: 1
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: backend.setWorkspaceFilter(modelData.workspace_id)
                        }
                    }
                }

                // Правая граница группы
                Rectangle { width: 1; height: 28; color: nord3 }
            }

            Rectangle {
                width: 110; height: 28
                opacity: currentRole === "manager" && backend.workspaceFilterId === -1 ? 0.35 : 1.0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                color: newTaskArea.containsMouse ? nord10 : nord9
                Behavior on color { ColorAnimation { duration: 100 } }
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "+ TASK"
                    color: nord0
                    font.family: "Monaspace Krypton"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }
                MouseArea {
                    id: newTaskArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        backend.load_statuses(backend.currentWorkspaceId)
                        // Для менеджера — грузим юзеров выбранного воркспейса фильтра
                        var wsId = currentRole === "manager"
                            ? backend.workspaceFilterId
                            : backend.currentWorkspaceId
                        backend.load_workspace_users(wsId)

                        if (backend.statuses.length === 0) {
                            noStatusError.visible = true
                            return
                        }
                        noStatusError.visible = false
                        newTaskDialog.selectedStatus = backend.statuses[0].status_id
                        newTaskDialog.selectedAssignee = 0
                        newTaskDialog.open()
                    }
                }
            }

            Text {
                id: noStatusError
                visible: false
                text: "// error: no statuses"
                color: "#BF616A"
                font.family: "Monaspace Krypton"
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 28; height: 28
                color: logoutArea.containsMouse ? "#3B2A2A" : "transparent"
                border.color: nord3
                border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                anchors.verticalCenter: parent.verticalCenter

                Text { anchors.centerIn: parent; text: "⏻"; color: nord11; font.pixelSize: 14 }
                MouseArea {
                    id: logoutArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: appWindow.pop()
                }
            }
        }
    }

    // ── Columns ──────────────────────────────────────────────
    Item {
        anchors.top: topBar.bottom
        anchors.bottom: statusBar.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Канбан — только когда выбран конкретный воркспейс
        Row {
            visible: currentRole !== "manager" || backend.workspaceFilterId !== -1
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 16
            spacing: 16

            Repeater {
                model: {
                    if (currentRole !== "manager")
                        return backend.statuses
                    return backend.statuses.filter(s => s.workspace_id === backend.workspaceFilterId)
                }

                Rectangle {
                    id: column
                    width: backend.statuses.length > 0
                        ? (root.width - 40 - 16 * (backend.statuses.length - 1)) / backend.statuses.length
                        : root.width - 40
                    height: parent.height
                    color: nord1
                    border.color: nord2
                    border.width: 1

                    Rectangle {
                        id: colHeader
                        width: parent.width
                        height: 36
                        color: nord2
                        anchors.top: parent.top

                        Rectangle {
                            width: 3; height: parent.height
                            color: modelData.color ?? nord8
                            anchors.left: parent.left
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Text {
                                text: modelData.name.toUpperCase()
                                color: nord4
                                font.family: "Monaspace Krypton"
                                font.pixelSize: 11
                                font.letterSpacing: 2
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                width: countText.implicitWidth + 10
                                height: 16
                                color: nord3

                                Text {
                                    id: countText
                                    anchors.centerIn: parent
                                    text: backend.tasks.filter(t => t.status_id === modelData.status_id).length
                                    color: nord4
                                    font.family: "Monaspace Krypton"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    ScrollView {
                        anchors.top: colHeader.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        anchors.topMargin: 10
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        Column {
                            width: parent.width
                            anchors.top: colHeader.bottom
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 8

                            Repeater {
                                model: backend.tasks.filter(t => t.status_id === modelData.status_id)

                                TaskCard {
                                    width: 260
                                    taskTitle: modelData.title
                                    taskDesc: modelData.description ?? ""
                                    deadline: modelData.deadline ?? ""
                                    priority: modelData.priority
                                    assignee: modelData.assignee_name ?? ""
                                    taskId: modelData.task_id
                                    workspaceName: currentRole === "manager" ? (modelData.workspace_name ?? "") : ""

                                    onCardClicked: (id) => {
                                        backend.selectTask(id)
                                        taskDetailDialog.open()
                                    }
                                }
                            }
                        }

                    }
                    DropArea {
                        anchors.top: colHeader.bottom  // только под хедером
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        keys: ["task"]
                        z: 10

                        Rectangle {
                            anchors.fill: parent
                            color: parent.containsDrag ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                            border.color: parent.containsDrag ? "#88C0D0" : "transparent"
                            border.width: 2
                        }

                        onDropped: function(drop) {
                            var tid = drop.source.taskId
                            backend.update_task_status(tid, modelData.status_id)
                        }
                        onEntered: console.log("enter:", modelData.name, "status_id:", modelData.status_id)
                    }
                }
            }
            }
            // Заглушка при ALL
            Column {
                visible: currentRole === "manager" && backend.workspaceFilterId === -1
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "// select department to view board"
                    color: nord3
                    font.family: "Monaspace Krypton"
                    font.pixelSize: 13
                    font.letterSpacing: 2
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: backend.tasks.length + " tasks total across all departments"
                    color: nord2
                    font.family: "Monaspace Krypton"
                    font.pixelSize: 11
                }
            }
        }

    // ── Status bar ───────────────────────────────────────────
    Rectangle {
        id: statusBar
        width: parent.width
        height: 28
        color: nord1
        anchors.bottom: parent.bottom

        Rectangle { width: parent.width; height: 1; color: nord2; anchors.top: parent.top }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 24

            Text { text: "tasks: " + backend.tasks.length; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
            Text { text: "//"; color: nord2; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
            Text { text: "NaviTime Kanban"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
        }
    }

    // ── Task Detail Dialog ───────────────────────────────────
    Popup {
        id: taskDetailDialog
        anchors.centerIn: parent
        width: 480
        height: 520
        modal: true
        padding: 0
        background: Rectangle { color: "transparent" }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: nord1
            border.color: nord8
            border.width: 2

            Rectangle { width: parent.width; height: 2; color: nord8; anchors.top: parent.top }
            Rectangle { width: 8; height: 8; color: nord8; anchors.top: parent.top; anchors.right: parent.right }
            Rectangle { width: 8; height: 8; color: nord8; anchors.bottom: parent.bottom; anchors.left: parent.left }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 14

                Text { text: "// TASK"; color: nord8; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 3 }

                Text {
                    text: backend.selectedTask ? backend.selectedTask.title : ""
                    color: nord4
                    font.family: "Monaspace Krypton"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: nord2 }

                Text {
                    text: backend.selectedTask ? (backend.selectedTask.description ?? "no description") : ""
                    color: nord3
                    font.family: "Monaspace Krypton"
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Grid {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Text { text: "deadline:"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12 }
                    Text { text: backend.selectedTask ? (backend.selectedTask.deadline ?? "—") : "—"; color: nord9; font.family: "Monaspace Krypton"; font.pixelSize: 12 }

                    Text { text: "assignee:"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12 }
                    Text { text: backend.selectedTask ? (backend.selectedTask.assignee_name ?? "—") : "—"; color: nord9; font.family: "Monaspace Krypton"; font.pixelSize: 12 }

                    Text { text: "priority:"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12 }
                    Text {
                        text: {
                            if (!backend.selectedTask) return "—"
                            var p = backend.selectedTask.priority
                            if (p === 4) return "!! CRITICAL"
                            if (p === 3) return "! high"
                            if (p === 2) return "medium"
                            return "low"
                        }
                        color: {
                            if (!backend.selectedTask) return nord3
                            var p = backend.selectedTask.priority
                            if (p === 4) return nord11
                            if (p === 3) return "#D08770"
                            return nord13
                        }
                        font.family: "Monaspace Krypton"; font.pixelSize: 12
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: nord2 }

                Text { text: "// comments"; color: nord8; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 2 }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: backend.selectedTaskComments
                            Text {
                                text: "→ " + modelData.author_name + ": " + modelData.body
                                color: nord4
                                font.family: "Monaspace Krypton"
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }
                    }
                }

                Row {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: parent.width - 80
                        height: 34
                        color: nord0
                        border.color: commentInput.activeFocus ? nord8 : nord2
                        border.width: 1

                        TextInput {
                            id: commentInput
                            anchors.fill: parent
                            anchors.margins: 8
                            color: nord4
                            font.family: "Monaspace Krypton"
                            font.pixelSize: 12
                            verticalAlignment: TextInput.AlignVCenter

                            Text {
                                text: "add comment..."
                                color: nord3
                                font: commentInput.font
                                visible: !commentInput.text
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: 72; height: 34
                        color: sendArea.containsMouse ? nord10 : nord9
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text { anchors.centerIn: parent; text: "→ SEND"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.weight: Font.Bold }
                        MouseArea {
                            id: sendArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (commentInput.text !== "") {
                                    backend.add_comment(backend.selectedTask.task_id, commentInput.text)
                                    commentInput.text = ""
                                }
                            }
                        }
                    }
                }

                Row {
                    spacing: 8

                    Rectangle {
                        width: 120; height: 32
                        color: deleteArea.containsMouse ? "#3B2A2A" : nord2
                        border.color: nord11; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text { anchors.centerIn: parent; text: "DELETE"; color: nord11; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 1 }
                        MouseArea {
                            id: deleteArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                backend.soft_delete_task(backend.selectedTask.task_id)
                                taskDetailDialog.close()
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true; height: 32
                    color: closeArea.containsMouse ? nord2 : "transparent"
                    border.color: nord3; border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text { anchors.centerIn: parent; text: "CLOSE"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 2 }
                    MouseArea { id: closeArea; anchors.fill: parent; hoverEnabled: true; onClicked: taskDetailDialog.close() }
                }
            }
        }
    }

    // ── New Task Dialog ──────────────────────────────────────
    Popup {
        id: newTaskDialog
        anchors.centerIn: parent
        width: 440
        height: 560
        modal: true
        padding: 0
        background: Rectangle { color: "transparent" }
        closePolicy: Popup.CloseOnEscape

        property int selectedStatus: backend.statuses.length > 0 ? backend.statuses[0].status_id : 0
        property int selectedAssignee: 0

        Rectangle {
            anchors.fill: parent
            color: nord1
            border.color: nord8; border.width: 2

            Rectangle { width: parent.width; height: 2; color: nord8; anchors.top: parent.top }
            Rectangle { width: 8; height: 8; color: nord8; anchors.top: parent.top; anchors.right: parent.right }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 10

                Text { text: "// NEW TASK"; color: nord8; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 3 }

                Text { text: "title"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 38
                    color: nord0; border.color: newTitle.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput {
                        id: newTitle
                        anchors.fill: parent; anchors.margins: 10
                        color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }

                Text { text: "description"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 60
                    color: nord0; border.color: nord2; border.width: 1
                    TextEdit {
                        id: newDesc
                        anchors.fill: parent; anchors.margins: 10
                        color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12
                        wrapMode: TextEdit.Wrap
                    }
                }

                Text { text: "status"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: {
                                if (currentRole !== "manager" || backend.workspaceFilterId === -1)
                                    return backend.statuses
                                return backend.statuses.filter(s => s.workspace_id === backend.workspaceFilterId)
                            }

                        Rectangle {
                            width: 100; height: 28
                            color: newTaskDialog.selectedStatus === modelData.status_id
                                   ? (modelData.color ?? nord10) : nord2
                            border.color: modelData.color ?? nord10
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                color: newTaskDialog.selectedStatus === modelData.status_id ? nord0 : nord4
                                font.family: "Monaspace Krypton"; font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: newTaskDialog.selectedStatus = modelData.status_id
                            }
                        }
                    }
                }

                Text { text: "priority"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Row {
                    spacing: 6
                    id: priorityRow

                    Repeater {
                        model: [
                            { val: 1, label: "low",      color: "#4C566A" },
                            { val: 2, label: "medium",   color: "#EBCB8B" },
                            { val: 3, label: "high",     color: "#D08770" },
                            { val: 4, label: "critical", color: "#BF616A" },
                        ]

                        Rectangle {
                            width: 78; height: 28
                            color: priorityRow.selectedVal === modelData.val ? modelData.color : nord2
                            border.color: modelData.color; border.width: 1
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: priorityRow.selectedVal === modelData.val ? nord0 : nord4
                                font.family: "Monaspace Krypton"; font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    priorityRow.selectedVal = modelData.val
                                    selectedPriority = modelData.val
                                }
                            }
                        }
                    }

                    property int selectedVal: 2
                }

                Text { text: "deadline (YYYY-MM-DD)"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 38
                    color: nord0; border.color: newDeadline.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput {
                        id: newDeadline
                        anchors.fill: parent; anchors.margins: 10
                        color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13
                        verticalAlignment: TextInput.AlignVCenter
                        inputMask: "9999-99-99"
                    }
                }

                Text { text: "assignee"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    // Кнопка "unassigned"
                    Rectangle {
                        width: 90; height: 28
                        color: newTaskDialog.selectedAssignee === 0 ? nord10 : nord2
                        border.color: nord10; border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text: "unassigned"
                            color: newTaskDialog.selectedAssignee === 0 ? nord0 : nord4
                            font.family: "Monaspace Krypton"; font.pixelSize: 10
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: newTaskDialog.selectedAssignee = 0
                        }
                    }

                    Repeater {
                        model: backend.workspaceUsers

                        Rectangle {
                            width: Math.max(90, usernameText.implicitWidth + 20)
                            height: 28
                            color: newTaskDialog.selectedAssignee === modelData.user_id ? nord9 : nord2
                            border.color: nord9; border.width: 1
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Text {
                                id: usernameText
                                anchors.centerIn: parent
                                text: modelData.username
                                color: newTaskDialog.selectedAssignee === modelData.user_id ? nord0 : nord4
                                font.family: "Monaspace Krypton"; font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: newTaskDialog.selectedAssignee = modelData.user_id
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Row {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 36
                        color: cancelNewArea.containsMouse ? nord2 : "transparent"
                        border.color: nord3; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CANCEL"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 1 }
                        MouseArea { id: cancelNewArea; anchors.fill: parent; hoverEnabled: true; onClicked: newTaskDialog.close() }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 36
                        color: createArea.containsMouse ? nord10 : nord9
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CREATE →"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1 }
                        MouseArea {
                            id: createArea; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                if (newTitle.text !== "" && newTaskDialog.selectedStatus !== 0) {
                                    var wsId = currentRole === "manager"
                                        ? backend.workspaceFilterId
                                        : backend.currentWorkspaceId
                                    backend.create_task(
                                        newTitle.text,
                                        newDesc.text,
                                        wsId,                          // ← правильный workspace
                                        newTaskDialog.selectedStatus,
                                        selectedPriority,
                                        newDeadline.text.replace(/-/g, "").trim() !== "" ? newDeadline.text : "",
                                        newTaskDialog.selectedAssignee
                                    )
                                    newTitle.text = ""
                                    newDesc.text = ""
                                    newDeadline.text = ""
                                    newTaskDialog.selectedAssignee = 0  // ← сброс
                                    newTaskDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
