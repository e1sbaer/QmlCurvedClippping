/*******************************************************************************
**
** Copyright (c) 2015 Lutz Schönemann <lutz.schoenemann@gmail.com>
**
**
** You may use this file under the terms of the MIT license:
**
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
** THE SOFTWARE.
**
*******************************************************************************/

import QtQuick 2.4
import QtGraphicalEffects 1.0

Item {
    id: root
    width: 300
    height: 300

    property real progressBarWidth: 20
    property color backgroundColor: "#fefefe"
    property color traceColor: "whitesmoke"
    property color textColor: "black"

    property string unit: "%"
    property real value: 55.5555
    property real minValue: 0
    property real maxValue: 100

    Rectangle {
        id: outerBackground
        anchors.fill: parent
        radius: Math.max(width, height)
        color: root.backgroundColor
        Rectangle {
            id: progressBarTrace
            anchors.fill: parent
            anchors.margins: progressBarWidth
            radius:  Math.max(width, height)
            color: root.traceColor
            Rectangle {
                id: innerBackground
                anchors.fill: parent
                anchors.margins: progressBarWidth
                radius: Math.max(width, height)
                color: root.backgroundColor
            }
        }
    }
    Item {
        id: indicatorContainer
        anchors.fill: parent
        anchors.margins: progressBarWidth

        property real normalizedValue: (root.value - root.minValue) / (root.maxValue - root.minValue)

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: innerBackground
        }

        Indicator {
            id: indicatorTopRight
            anchors.left: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            width: Math.max(parent.width, parent.height) / 2
            height: width
            angle: indicatorContainer.normalizedValue * 360 - rotation
        }
        Indicator {
            id: indicatorBottomRight
            anchors.left: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            width: Math.max(parent.width, parent.height) / 2
            height: width
            angle: indicatorContainer.normalizedValue * 360 - rotation
            rotation: 90
        }
        Indicator {
            id: indicatorBottomLeft
            anchors.right: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            width: Math.max(parent.width, parent.height) / 2
            height: width
            angle: indicatorContainer.normalizedValue * 360 - rotation
            rotation: 180
        }
        Indicator {
            id: indicatorTopLeft
            anchors.right: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            width: Math.max(parent.width, parent.height) / 2
            height: width
            angle: indicatorContainer.normalizedValue * 360 - rotation
            rotation: 270
        }
    }
    Item {
        id: textContainer
        anchors.centerIn: parent
        height: childrenRect.height
        width: childrenRect.width

        Text {
            id: valueText
            font.pixelSize: innerBackground.height / 3
            font.family: "Cursive"
            color: root.textColor
            text: Math.round(root.value * 10) / 10 //root.value
        }
        Text {
            id: unitText
            anchors.baseline: valueText.baseline
            anchors.left: valueText.right
            font.pixelSize: valueText.font.pixelSize / 3
            font.family: "Cursive"
            color: root.textColor
            text: root.unit
        }
    }
}
