import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    title: "NaviTime // Kanban"
    color: "#2E3440"

    FontLoader {
        source: Qt.resolvedUrl("../fonts/MonaspaceKrypton-Regular.otf")
    }

    Loader {
        id: stack
        anchors.fill: parent
        source: Qt.resolvedUrl("LoginWindow.qml")

        onLoaded: {
            item.width  = Qt.binding(() => appWindow.width)
            item.height = Qt.binding(() => appWindow.height)
        }
    }

    function push(url) {
        stack.source = url
    }

    function pop() {
        stack.source = Qt.resolvedUrl("LoginWindow.qml")
    }
}
