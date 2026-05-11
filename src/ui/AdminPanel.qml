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
    readonly property color nord15: "#B48EAD"

    property int activeTab: 0  // 0=users 1=workspaces 2=statuses

    Component.onCompleted: {
        backend.load_users()
        backend.load_workspaces()
        backend.load_statuses(0)  // все статусы или по workspace
    }

    // ── Top bar ──────────────────────────────────────────────
    Rectangle {
        id: topBar
        width: parent.width
        height: 48
        color: nord1
        anchors.top: parent.top
        z: 10

        Rectangle { width: parent.width; height: 2; color: nord15; anchors.top: parent.top }
        Rectangle { width: parent.width; height: 1; color: nord2; anchors.bottom: parent.bottom }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Text { text: "//"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 14 }
            Text { text: "ADMIN PANEL"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 14; font.weight: Font.Bold; font.letterSpacing: 2 }
            Rectangle { width: 1; height: 20; color: nord2 }
            Text { text: "NaviTime Kanban"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12 }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text { text: backend.currentUser; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 12 }

            Rectangle {
                width: 28; height: 28
                color: logoutArea.containsMouse ? "#3B2A2A" : "transparent"
                border.color: nord3; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
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

    // ── Sidebar ──────────────────────────────────────────────
    Rectangle {
        id: sidebar
        width: 200
        anchors.top: topBar.bottom
        anchors.bottom: statusBar.top
        anchors.left: parent.left
        color: nord1

        Rectangle { width: 1; height: parent.height; color: nord2; anchors.right: parent.right }

        Column {
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            Text {
                text: "// CONTROL PANEL"
                color: nord3
                font.family: "Monaspace Krypton"
                font.pixelSize: 10
                font.letterSpacing: 2
                leftPadding: 16
                bottomPadding: 10
            }

            Repeater {
                model: [
                    { icon: "◈", label: "USERS",       idx: 0 },
                    { icon: "◫", label: "WORKSPACES",  idx: 1 },
                    { icon: "◧", label: "STATUSES",    idx: 2 },
                ]

                Rectangle {
                    width: parent.width
                    height: 40
                    color: activeTab === modelData.idx ? nord2 : (tabArea.containsMouse ? "#383F50" : "transparent")
                    Behavior on color { ColorAnimation { duration: 80 } }

                    Rectangle {
                        width: 3; height: parent.height
                        color: nord15
                        visible: activeTab === modelData.idx
                        anchors.left: parent.left
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: activeTab === modelData.idx ? 20 : 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Behavior on anchors.leftMargin { NumberAnimation { duration: 100 } }

                        Text { text: modelData.icon; color: nord15; font.pixelSize: 14 }
                        Text {
                            text: modelData.label
                            color: activeTab === modelData.idx ? nord4 : nord3
                            font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 1
                        }
                    }

                    MouseArea { id: tabArea; anchors.fill: parent; hoverEnabled: true; onClicked: activeTab = modelData.idx }
                }
            }
        }
    }

    // ── Main content ─────────────────────────────────────────
    Rectangle {
        anchors.top: topBar.bottom
        anchors.bottom: statusBar.top
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.margins: 20
        color: "transparent"

        // ── USERS TAB ────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            visible: activeTab === 0

            Row {
                spacing: 12
                Layout.fillWidth: true

                Text { text: "// USERS"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 13; font.letterSpacing: 2 }
                Item { width: 1; height: 1; Layout.fillWidth: true }

                Rectangle {
                    width: 120; height: 32
                    color: addUserArea.containsMouse ? nord15 : nord9
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "+ USER"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1 }
                    MouseArea { id: addUserArea; anchors.fill: parent; hoverEnabled: true; onClicked: addUserDialog.open() }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 32; color: nord2

                Row {
                    anchors.fill: parent; anchors.leftMargin: 12

                    Repeater {
                        model: [
                            { label: "ID",        w: 50  },
                            { label: "USERNAME",  w: 150 },
                            { label: "NAME",      w: 180 },
                            { label: "ROLE",      w: 110 },
                            { label: "WORKSPACE", w: 120 },
                            { label: "STATUS",    w: 90  },
                            { label: "ACTIONS",   w: 120 },
                        ]
                        Text { width: modelData.w; height: parent.height; text: modelData.label; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.letterSpacing: 1; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width; spacing: 2

                    Repeater {
                        model: backend.users

                        Rectangle {
                            width: parent.width; height: 38
                            color: rowArea.containsMouse ? nord2 : (index % 2 === 0 ? nord1 : "#363D4E")
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Row {
                                anchors.fill: parent; anchors.leftMargin: 12

                                Text { width: 50;  height: parent.height; text: modelData.user_id;   color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Text { width: 150; height: parent.height; text: modelData.username;  color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Text { width: 180; height: parent.height; text: modelData.full_name; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text {
                                    width: 110; height: parent.height
                                    text: modelData.role
                                    color: modelData.role === "admin" ? nord15 : (modelData.role === "manager" ? nord13 : nord9)
                                    font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter
                                }
                                Text { width: 120; height: parent.height; text: modelData.workspace_name ?? "—"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }

                                Rectangle {
                                    width: 70; height: 20; anchors.verticalCenter: parent.verticalCenter
                                    color: modelData.is_active ? "#1A2E1A" : "#2E1A1A"
                                    border.color: modelData.is_active ? nord14 : nord11; border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.is_active ? "ACTIVE" : "INACTIVE"; color: modelData.is_active ? nord14 : nord11; font.family: "Monaspace Krypton"; font.pixelSize: 9; font.letterSpacing: 1 }
                                }

                                Rectangle {
                                    width: 80; height: 24; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 8
                                    color: toggleArea.containsMouse ? (modelData.is_active ? "#3B2A2A" : "#1A2E1A") : "transparent"
                                    border.color: modelData.is_active ? nord11 : nord14; border.width: 1
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    Text { anchors.centerIn: parent; text: modelData.is_active ? "DEACT." : "ACTIV."; color: modelData.is_active ? nord11 : nord14; font.family: "Monaspace Krypton"; font.pixelSize: 9; font.letterSpacing: 1 }
                                    MouseArea { id: toggleArea; anchors.fill: parent; hoverEnabled: true; onClicked: backend.toggle_user_active(modelData.user_id, !modelData.is_active) }
                                }
                            }

                            MouseArea { id: rowArea; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }
                        }
                    }
                }
            }
        }

        // ── WORKSPACES TAB ───────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            visible: activeTab === 1

            Row {
                spacing: 12; Layout.fillWidth: true
                Text { text: "// WORKSPACES"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 13; font.letterSpacing: 2 }
                Item { width: 1; height: 1; Layout.fillWidth: true }
                Rectangle {
                    width: 140; height: 32
                    color: addWSArea.containsMouse ? nord15 : nord9
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "+ WORKSPACE"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1 }
                    MouseArea { id: addWSArea; anchors.fill: parent; hoverEnabled: true; onClicked: addWSDialog.open() }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 32; color: nord2
                Row { anchors.fill: parent; anchors.leftMargin: 12
                    Repeater {
                        model: [{ label: "ID", w: 60 }, { label: "NAME", w: 300 }, { label: "CREATED", w: 200 }, { label: "ACTIONS", w: 120 }]
                        Text { width: modelData.w; height: parent.height; text: modelData.label; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.letterSpacing: 1; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Column {
                    width: parent.width; spacing: 2
                    Repeater {
                        model: backend.workspaces
                        Rectangle {
                            width: parent.width; height: 38
                            color: wsRowArea.containsMouse ? nord2 : (index % 2 === 0 ? nord1 : "#363D4E")
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 12
                                Text { width: 60;  height: parent.height; text: modelData.workspace_id; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Text { width: 300; height: parent.height; text: modelData.name;         color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Text { width: 200; height: parent.height; text: modelData.created_at;  color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11; verticalAlignment: Text.AlignVCenter }
                                Rectangle {
                                    width: 80; height: 24; anchors.verticalCenter: parent.verticalCenter
                                    color: delWSArea.containsMouse ? "#3B2A2A" : "transparent"; border.color: nord11; border.width: 1
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    Text { anchors.centerIn: parent; text: "DELETE"; color: nord11; font.family: "Monaspace Krypton"; font.pixelSize: 9; font.letterSpacing: 1 }
                                    MouseArea { id: delWSArea; anchors.fill: parent; hoverEnabled: true; onClicked: backend.delete_workspace(modelData.workspace_id) }
                                }
                            }
                            MouseArea { id: wsRowArea; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }
                        }
                    }
                }
            }
        }

        // ── STATUSES TAB ─────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            visible: activeTab === 2

            Row {
                spacing: 12; Layout.fillWidth: true
                Text { text: "// STATUSES"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 13; font.letterSpacing: 2 }
                Item { width: 1; height: 1; Layout.fillWidth: true }

                // Workspace picker для статусов
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Text { text: "workspace:"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    ComboBox {
                        id: statusWsCombo
                        width: 160
                        model: backend.workspaces.map(w => w.name)
                        font.family: "Monaspace Krypton"
                        background: Rectangle { color: nord0; border.color: nord2; border.width: 1 }
                        contentItem: Text { leftPadding: 10; text: statusWsCombo.displayText; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                        onCurrentIndexChanged: {
                            if (backend.workspaces.length > currentIndex)
                                backend.load_statuses(backend.workspaces[currentIndex].workspace_id)
                        }
                    }
                }

                Rectangle {
                    width: 120; height: 32
                    color: addStatusArea.containsMouse ? nord15 : nord9
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "+ STATUS"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1 }
                    MouseArea { id: addStatusArea; anchors.fill: parent; hoverEnabled: true; onClicked: addStatusDialog.open() }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 32; color: nord2
                Row { anchors.fill: parent; anchors.leftMargin: 12
                    Repeater {
                        model: [{ label: "ID", w: 60 }, { label: "NAME", w: 200 }, { label: "COLOR", w: 120 }, { label: "POSITION", w: 100 }, { label: "ACTIONS", w: 120 }]
                        Text { width: modelData.w; height: parent.height; text: modelData.label; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 10; font.letterSpacing: 1; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Column {
                    width: parent.width; spacing: 2
                    Repeater {
                        model: backend.statuses
                        Rectangle {
                            width: parent.width; height: 38
                            color: stRowArea.containsMouse ? nord2 : (index % 2 === 0 ? nord1 : "#363D4E")
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 12; spacing: 0
                                Text { width: 60;  height: parent.height; text: modelData.status_id; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Text { width: 200; height: parent.height; text: modelData.name;      color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Row {
                                    width: 120; height: parent.height
                                    spacing: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    Rectangle { width: 16; height: 16; color: modelData.color ?? "#5E81AC"; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: modelData.color ?? "—"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Text { width: 100; height: parent.height; text: modelData.position;  color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 12; verticalAlignment: Text.AlignVCenter }
                                Rectangle {
                                    width: 80; height: 24; anchors.verticalCenter: parent.verticalCenter
                                    color: delStArea.containsMouse ? "#3B2A2A" : "transparent"; border.color: nord11; border.width: 1
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    Text { anchors.centerIn: parent; text: "DELETE"; color: nord11; font.family: "Monaspace Krypton"; font.pixelSize: 9; font.letterSpacing: 1 }
                                    MouseArea {
                                        id: delStArea; anchors.fill: parent; hoverEnabled: true
                                        onClicked: {
                                            var wsId = backend.workspaces.length > statusWsCombo.currentIndex
                                                ? backend.workspaces[statusWsCombo.currentIndex].workspace_id : 0
                                            backend.delete_status(modelData.status_id, wsId)
                                        }
                                    }
                                }
                            }
                            MouseArea { id: stRowArea; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true }
                        }
                    }
                }
            }
        }
    }

    // ── Status bar ───────────────────────────────────────────
    Rectangle {
        id: statusBar
        width: parent.width; height: 28
        color: nord1; anchors.bottom: parent.bottom
        Rectangle { width: parent.width; height: 1; color: nord2; anchors.top: parent.top }
        Row {
            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 24
            Text { text: "users: " + backend.users.length; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
            Text { text: "workspaces: " + backend.workspaces.length; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
            Text { text: "statuses: " + backend.statuses.length; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
        }
    }

    // ── Add User Dialog ──────────────────────────────────────
    Popup {
        id: addUserDialog
        anchors.centerIn: parent
        width: 420; height: 460
        modal: true; padding: 0
        background: Rectangle { color: "transparent" }
        closePolicy: Popup.CloseOnEscape

        Rectangle {
            anchors.fill: parent; color: nord1; border.color: nord15; border.width: 2
            Rectangle { width: parent.width; height: 2; color: nord15; anchors.top: parent.top }
            Rectangle { width: 8; height: 8; color: nord15; anchors.top: parent.top; anchors.right: parent.right }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 28; spacing: 10

                Text { text: "// NEW USER"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 3 }

                Text { text: "username"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: nord0; border.color: uField.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput { id: uField; anchors.fill: parent; anchors.margins: 10; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; verticalAlignment: TextInput.AlignVCenter }
                }

                Text { text: "full name"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: nord0; border.color: nField.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput { id: nField; anchors.fill: parent; anchors.margins: 10; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; verticalAlignment: TextInput.AlignVCenter }
                }

                Text { text: "password"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: nord0; border.color: pField.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput { id: pField; anchors.fill: parent; anchors.margins: 10; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; echoMode: TextInput.Password; verticalAlignment: TextInput.AlignVCenter }
                }

                Text { text: "role"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Row {
                    spacing: 8
                    id: roleSelector
                    property string selected: "employee"

                    Repeater {
                        model: [
                            { val: "employee", label: "employee", color: "#81A1C1" },
                            { val: "manager",  label: "manager",  color: "#EBCB8B" },
                            { val: "admin",    label: "admin",    color: "#B48EAD" },
                        ]
                        Rectangle {
                            width: 100; height: 28
                            color: roleSelector.selected === modelData.val ? modelData.color : nord2
                            border.color: modelData.color; border.width: 1
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text { anchors.centerIn: parent; text: modelData.label; color: roleSelector.selected === modelData.val ? nord0 : nord4; font.family: "Monaspace Krypton"; font.pixelSize: 10 }
                            MouseArea { anchors.fill: parent; onClicked: roleSelector.selected = modelData.val }
                        }
                    }
                }

                Text { text: "workspace"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11; visible: roleSelector.selected === "employee" }
                ComboBox {
                    id: wsCombo
                    visible: roleSelector.selected === "employee"
                    Layout.fillWidth: true
                    model: backend.workspaces.map(w => w.name)
                    font.family: "Monaspace Krypton"
                    background: Rectangle { color: nord0; border.color: nord2; border.width: 1 }
                    contentItem: Text { leftPadding: 10; text: wsCombo.displayText; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter }
                }

                Item { Layout.fillHeight: true }

                Row {
                    Layout.fillWidth: true; spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: cancelUA.containsMouse ? nord2 : "transparent"; border.color: nord3; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CANCEL"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                        MouseArea { id: cancelUA; anchors.fill: parent; hoverEnabled: true; onClicked: addUserDialog.close() }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: createUA.containsMouse ? nord15 : nord9
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CREATE →"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.weight: Font.Bold }
                        MouseArea {
                            id: createUA; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                if (uField.text === "" || nField.text === "" || pField.text === "") return
                                var wsId = roleSelector.selected === "employee" && backend.workspaces.length > 0
                                    ? backend.workspaces[wsCombo.currentIndex].workspace_id : null
                                backend.create_user(uField.text, nField.text, pField.text, roleSelector.selected, wsId)
                                uField.text = ""; nField.text = ""; pField.text = ""
                                addUserDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Add Workspace Dialog ─────────────────────────────────
    Popup {
        id: addWSDialog
        anchors.centerIn: parent
        width: 360; height: 200
        modal: true; padding: 0
        background: Rectangle { color: "transparent" }
        closePolicy: Popup.CloseOnEscape

        Rectangle {
            anchors.fill: parent; color: nord1; border.color: nord15; border.width: 2
            Rectangle { width: parent.width; height: 2; color: nord15; anchors.top: parent.top }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 28; spacing: 12

                Text { text: "// NEW WORKSPACE"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 3 }
                Text { text: "name"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }

                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: nord0; border.color: wsNameInput.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput { id: wsNameInput; anchors.fill: parent; anchors.margins: 10; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; verticalAlignment: TextInput.AlignVCenter }
                }

                Row {
                    Layout.fillWidth: true; spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: cWsCancel.containsMouse ? nord2 : "transparent"; border.color: nord3; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CANCEL"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                        MouseArea { id: cWsCancel; anchors.fill: parent; hoverEnabled: true; onClicked: addWSDialog.close() }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: cWsCreate.containsMouse ? nord15 : nord9
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CREATE →"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.weight: Font.Bold }
                        MouseArea {
                            id: cWsCreate; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                if (wsNameInput.text !== "") {
                                    backend.create_workspace(wsNameInput.text)
                                    wsNameInput.text = ""
                                    addWSDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Add Status Dialog ────────────────────────────────────
    Popup {
        id: addStatusDialog
        anchors.centerIn: parent
        width: 380; height: 240
        modal: true; padding: 0
        background: Rectangle { color: "transparent" }
        closePolicy: Popup.CloseOnEscape

        Rectangle {
            anchors.fill: parent; color: nord1; border.color: nord15; border.width: 2
            Rectangle { width: parent.width; height: 2; color: nord15; anchors.top: parent.top }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 28; spacing: 12

                Text { text: "// NEW STATUS"; color: nord15; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.letterSpacing: 3 }
                Text { text: "name"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }

                Rectangle {
                    Layout.fillWidth: true; height: 36
                    color: nord0; border.color: statusNameInput.activeFocus ? nord8 : nord2; border.width: 1
                    TextInput { id: statusNameInput; anchors.fill: parent; anchors.margins: 10; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 13; verticalAlignment: TextInput.AlignVCenter }
                }

                Text { text: "color"; color: nord3; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                Row {
                    spacing: 8
                    id: colorPicker
                    property string selectedColor: "#5E81AC"

                    Repeater {
                        model: ["#5E81AC", "#88C0D0", "#A3BE8C", "#EBCB8B", "#D08770", "#BF616A", "#B48EAD"]
                        Rectangle {
                            width: 28; height: 28
                            color: modelData
                            border.color: colorPicker.selectedColor === modelData ? "white" : "transparent"
                            border.width: 2
                            MouseArea { anchors.fill: parent; onClicked: colorPicker.selectedColor = modelData }
                        }
                    }
                }

                Row {
                    Layout.fillWidth: true; spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: csCancelArea.containsMouse ? nord2 : "transparent"; border.color: nord3; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CANCEL"; color: nord4; font.family: "Monaspace Krypton"; font.pixelSize: 11 }
                        MouseArea { id: csCancelArea; anchors.fill: parent; hoverEnabled: true; onClicked: addStatusDialog.close() }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2; height: 34
                        color: csCreateArea.containsMouse ? nord15 : nord9
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "CREATE →"; color: nord0; font.family: "Monaspace Krypton"; font.pixelSize: 11; font.weight: Font.Bold }
                        MouseArea {
                            id: csCreateArea; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                if (statusNameInput.text !== "" && backend.workspaces.length > statusWsCombo.currentIndex) {
                                    var wsId = backend.workspaces[statusWsCombo.currentIndex].workspace_id
                                    backend.create_status(wsId, statusNameInput.text, colorPicker.selectedColor)
                                    statusNameInput.text = ""
                                    addStatusDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
