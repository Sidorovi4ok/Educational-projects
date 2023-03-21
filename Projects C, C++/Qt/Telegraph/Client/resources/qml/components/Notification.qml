import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: "#282e33"
    visible: false

    signal open(title: string, discription: string)

    Connections {
        target: root
        function onOpen(title, discription) {
            titleNot.text = title
            descriptionNot.text = discription
            root.visible = true
            main.open()
        }
    }

    Popup {
        id: main
        parent: Overlay.overlay
        width:  300; height: 75

        modal: true
        focus: true
        padding: 3

        x: Math.round((parent.width  - width) / 2)
        y: 5

        Rectangle {
            anchors.fill: parent

            radius: 10
            color: "#282e33"

            Label {
                id: titleNot

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.topMargin: 10

                color: "white"
                font.bold: true
                font.pointSize: 10
            }

            Label {
                id: descriptionNot

                anchors.top: titleNot.bottom
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.topMargin: 10

                color: "white"
                font.pointSize: 9
                font.italic: true
            }

            Button {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.topMargin: 5

                flat: true

                icon.width: 10
                icon.height: 10
                icon.color: "#AAAAAA"
                icon.source: "../../icons/close.png"

                background: Rectangle {
                    opacity: 0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        main.close()
                    }
                }
            }
        }

        background: Rectangle {
            color: "#313840"
            radius: 10
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0;
                duration: 200
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0
                to: 0.0;
                duration: 200
            }
        }
    }
}
