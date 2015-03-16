import QtQuick 2.4

MainForm {
    mouseArea.onClicked: {
        Qt.quit();
    }

    PropertyAnimation {
        target: gauge
        property: "value"
        from: 0
        to: 100
        loops: Animation.Infinite
        duration: 5000
        easing.type: Easing.InOutCubic
        running: true
    }
}
