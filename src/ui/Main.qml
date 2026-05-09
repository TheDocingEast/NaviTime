import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 1200
    height: 800
    title: "Kanban"

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: Qt.resolvedUrl("LoginWindow.qml")
    }
}
