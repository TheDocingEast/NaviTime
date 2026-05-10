import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 800
    color: "#2E3440"

    FontLoader {
        source: Qt.resolvedUrl("../fonts/MonaspaceKrypton-Regular.otf")
    }

    Loader {
        id: stack
        anchors.fill: parent
        source: Qt.resolvedUrl("LoginWindow.qml")

        onLoaded: {
            item.width  = Qt.binding(() => root.width)
            item.height = Qt.binding(() => root.height)
        }
    }

    function push(url) {
        stack.source = url
    }

    function pop() {
        stack.source = Qt.resolvedUrl("LoginWindow.qml")
    }
}
