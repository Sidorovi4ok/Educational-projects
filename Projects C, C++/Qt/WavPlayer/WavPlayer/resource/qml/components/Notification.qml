import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    z: 100
    visible: false

    color: "#212121"
    radius: 10
    border.width: 2
    border.color: "#0F0F0F"

    property alias notificationTitle: rootTitle
    property alias descriptionText: descriptionText
    property alias notificationAnimation: notificationAppend

    Text {
        id: rootTitle

        anchors.top: parent.top
        anchors.left: parent.left

        anchors.topMargin: 8
        anchors.leftMargin: 8

        color: "#AAAAAA"
        font.bold: true
        font.italic: true

        font.pointSize: 13
    }

    Rectangle {
        id: rootDescription

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 41

        color: "#212121"
        radius: parent.radius
        border.width: 2
        border.color: "#0F0F0F"

        Text {
            id: descriptionText

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8

            color: "#AAAAAA"
            font.italic: true
            font.pointSize: 11

            wrapMode: Text.WordWrap
        }
    }

    Button {
        id: closeRoot

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 4
        anchors.rightMargin: 4

        width: 12; height: 12

        text: "Close"

        onClicked: ParallelAnimation {

            NumberAnimation {
                target: root
                property: "scale"
                from: 1
                to: 0
                duration: 200
            }

            NumberAnimation {
                target: root
                property: "visible"
                from: 1
                to: 0
                duration: 200
            }
        }
    }

    ParallelAnimation {
        id: notificationAppend

        SmoothedAnimation {
            target: root
            property: "y"
            from: 0
            to: 5
            duration: 100
        }

        NumberAnimation {
            target: root
            property: "visible"
            from: 0
            to: 1
            duration: 350
        }

        NumberAnimation {
            target: root
            property: "scale"
            from: 0
            to: 1
            duration: 250
        }
    }
}

