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

Item {
    id: root
    width: 150
    height: 150
    clip: true

    property real angle: 33.3
    property color color: "royalblue"

    Rectangle {
        id: indicator
        transform: Rotation {
            angle: -90 + Math.max(0, Math.min(root.angle, 90))
            origin.y: indicator.height
        }
        width: Math.max(parent.width, parent.height)
        height: width
        y: parent.height - height
        color: root.color
    }
}

