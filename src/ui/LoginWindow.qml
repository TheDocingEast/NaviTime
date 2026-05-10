import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#2E3440"

    Rectangle {
        width: parent.width
        height: 3
        color: "#88C0D0"
        anchors.top: parent.top
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: 320

        Text {
            text: "// NAVITIME KANBAN"
            color: "#88C0D0"
            font.pixelSize: 13
            font.letterSpacing: 4
            font.family: "Monaspace Krypton"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "AUTHORIZATION"
            color: "#D8DEE9"
            font.pixelSize: 22
            font.bold: true
            font.family: "Monaspace Krypton"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#434C5E" }

        Text { text: "login"; color: "#4C566A"; font.pixelSize: 11; font.family: "Monaspace Krypton" }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#3B4252"
            border.color: loginField.activeFocus ? "#88C0D0" : "#434C5E"
            border.width: 1

            TextInput {
                id: loginField
                anchors.fill: parent
                anchors.margins: 10
                color: "#D8DEE9"
                font.pixelSize: 14
                font.family: "Monaspace Krypton"
                verticalAlignment: TextInput.AlignVCenter
            }
        }

        Text { text: "password"; color: "#4C566A"; font.pixelSize: 11; font.family: "Monaspace Krypton" }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#3B4252"
            border.color: passField.activeFocus ? "#88C0D0" : "#434C5E"
            border.width: 1

            TextInput {
                id: passField
                anchors.fill: parent
                anchors.margins: 10
                color: "#D8DEE9"
                font.pixelSize: 14
                font.family: "Monaspace Krypton"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                Keys.onReturnPressed: doLogin()
            }
        }

        Text {
            id: errorText
            text: ""
            color: "#BF616A"
            font.pixelSize: 11
            font.family: "Monaspace Krypton"
            visible: text !== ""
        }

        Rectangle {
            Layout.fillWidth: true
            height: 42
            color: btnArea.pressed ? "#5E81AC" : (btnArea.containsMouse ? "#5E81AC" : "#81A1C1")

            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: "LOGIN →"
                color: "#2E3440"
                font.pixelSize: 13
                font.bold: true
                font.letterSpacing: 2
                font.family: "Monaspace Krypton"
            }

            MouseArea {
                id: btnArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: doLogin()
            }
        }
    }

    function doLogin() {
        var result = backend.login(loginField.text, passField.text)
        if (result === "admin") {
            root.push(Qt.resolvedUrl("AdminPanel.qml"))
        } else if (result === "board") {
            root.push(Qt.resolvedUrl("Board.qml"))
        } else {
            errorText.text = "// incorrect login or password"
        }
    }

    Rectangle {
        width: parent.width
        height: 28
        color: "#3B4252"
        anchors.bottom: parent.bottom
        Rectangle { width: parent.width; height: 1; color: "#434C5E"; anchors.top: parent.top }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "// NaviTime Kanban v0.3"
            color: "#4C566A"
            font.pixelSize: 11
            font.family: "Monaspace Krypton"
        }
    }
}
