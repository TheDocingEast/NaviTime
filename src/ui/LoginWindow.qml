import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    anchors.fill: parent  // ← вот это
    color: "#1e1e2e"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        TextField {
            id: loginField
            placeholderText: "Логин"
            Layout.preferredWidth: 300
        }

        TextField {
            id: passField
            placeholderText: "Пароль"
            echoMode: TextInput.Password
            Layout.preferredWidth: 300
        }

        Button {
            text: "Войти"
            Layout.fillWidth: true
            onClicked: {
                if (backend.login(loginField.text, passField.text)) {
                    stack.push(Qt.resolvedUrl("Board.qml"));
                }
            }
        }
    }
}
