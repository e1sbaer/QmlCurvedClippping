import QtQuick 2.3
import "Gauge"

Rectangle {
    property alias mouseArea: mouseArea
    property alias gauge: gauge

    width: 360
    height: 360

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }

    Gauge {
        id: gauge
        anchors.fill: parent
        anchors.margins: progressBarWidth
    }
}
