Clipping along round edges
==========================

QML supports clipping along the edges of a rectangular item. It is very easy to use (just setting property _clip_ to _true_) and pretty helpful. But it also has two major disadvantages:
1. Clipping does not produce smooth edges (e.g. when clipping in rotated items)
2. Even when creating _Rectangles_ with rounded corners clipping does not work on these visual edges but only on the _Items_ real edges that is always a rectangle

This little project demonstrates how you can visually clip your items very easy to the edges of an other item. The downside is that you can still click _MouseAreas_ that should be clipped away.  
We'll create a roundly gauge element in 6 easy to follow steps. At the end of each step I'll name the commit you can see the changeds I've made.


TL;DR
-----
- enable layering of your _Item_ that should be clipped (__layer.enable: true__)
- make a _OpacityMask_ be the __layer.effect__ of that item
- set the _OpacityMask_'s __maskSource__ property to the clipping _Item_


Create a QML project
--------------------
The first step is to create a new QML project. I just used the _Qt Quick UI_ project the QtCreator can create out of the box:
1. Click '_File_' > '_New File or Project..._'
2. Make sure to select _All Templates_ from the drop down in the top-right corner
3. Select '_Application_' > '_Qt Quick UI_'

Now we have a simple application that shows us the message "Hello World" when we hit _run_.

See: 64b949b (Initial commit)


Add the basic layout of the gauge element
-----------------------------------------
To make our element reusable we put it into an separate file (_Gauge.qml_).  
As root element we keep the plain _Item_ and place 3 nested _Rectangles_ in it:

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

I also placed some text inside the element to show the value as string.

In the file _MainForm.ui.qml_ I replaced the _Text_ element by the newly created Gauge:

    Gauge {
        anchors.fill: parent
        anchors.margins: progressBarWidth
    }

See: 40b06aa (Add gauge layout)


Add rectangles used to display the progress bar
-----------------------------------------------
We create a new item that acts as indicator. What it does is it rotates a rectangle into the visible area of it's parent. Input value range is from _0_ (fully rotated out of view) to 90 (fully visible):

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

In our gauge we use 4 of those items each rotated and positioned in one quadrant of the gauge element. Also the input values are adjusted by subtracting the indicators rotation:

    Item {
            id: indicatorContainer
            anchors.fill: parent
            anchors.margins: progressBarWidth

            property real normalizedValue: (root.value - root.minValue) / (root.maxValue - root.minValue)

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

See: 5b2319d (Add indicator rectangles)


Breathing life into it
----------------------
For a better understanding and to detect errors faster we add an animation of the gauge value. Therefor we'll use a infinite _PropertyAnimation_:

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

See: 4e52f97 (Animate the gauge value)


Clipping indicator into a circle shape
--------------------------------------
Clipping the outer edges of our indicators is a very easy step. Therefor we use the _OpacityMask_ form Qt's QtGraphicalEffects module and apply as layer effect of the _inicatorContainer_ item:

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: innerBackground
            }

What it does is it uses the _maskSource_ item's opacity and applies it to the target item.

-----

__NOTE:__ Using this technique to cut away unwanted visual parts is easy and fast but is no real clipping. That means mouse events can still trigger MouseAreas positioned in areas that should be cut away!

-----

See: ea32c58 (Add OpacityMask layer)


Finally: Clipping indicator into the shape of the progress bar
--------------------------------------------------------------
We could omit the last step if we'd move the _indicatorContainer_ item below the _innerBackground_ item. That would cover the inner part of the indicator and just show our bar instead of the full disc.  
For the reason to show that we not only can clip the outer parts but also can punch holes into items we'll add an additional shader.

At first we wrap the _innerBackground_ item in an additional Item (_innerMaskSource_) that fills it's parent (_progressBarTrace_).  
The reason for that additional item is, that we want to use the _innerBackground_ as mask for the indicator items. Because a shader does not know about pixels in a texture and doesn't care about sizes of textures it would "stretch" the mask to fit the target texture. That would lead to that we try to punch a hole into the item that is the same size as the item itself.  
Now that we have wrapped the _innerBackground_ and use the _innerMaskSource_ as maskSource we have in additional margin added to our mask texture.

    Item {
        id: innerMaskSource
        anchors.fill: parent
        layer.enabled: true
        Rectangle {
            id: innerBackground
            anchors.fill: parent
            anchors.margins: progressBarWidth
            radius: Math.max(width, height)
            color: root.backgroundColor
        }
    }

Finally we wrap the 4 _Indicator_ items into an additional _Item_. That additional item has layering enabled and as _layer.effect_ we define a new shader.  
The shader nearly does the same as the OpacityMask except for it multiplies the output by the negated value of _maskSource_ alpha value:

    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source
            property variant maskSource: innerMaskSource

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform highp float qt_Opacity;
                uniform lowp sampler2D source;
                uniform lowp sampler2D maskSource;
                void main(void) {
                    gl_FragColor = texture2D(source, qt_TexCoord0.st) * (1.0 - texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
                }
            "
        }
        Indicator {
    //        ...
        }
        Indicator {
    //        ...
        }
        Indicator {
    //        ...
        }
        Indicator {
    //        ...
        }
    }


See: 99d7080 (Add inverted OpacityMask layer to clip inner circle)
