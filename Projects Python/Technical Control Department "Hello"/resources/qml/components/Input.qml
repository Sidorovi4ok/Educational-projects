import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    height: 40
    color: "transparent"

    property string placeholder: ""

    function getText() { return input.text }
    function clear()   { input.text = ""   }

    TextInput {
        id: input

        anchors.leftMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        font.pointSize: 10
        color: "white"
        clip: true

        Label {
            id: inputPlaceholder
            anchors.fill: parent

            opacity: (parent.text !== "") ? 0 : 0.6
            font.pointSize: input.font.pointSize

            color: "#AAAAAA"
            text: root.placeholder
        }
    }

    Rectangle {
        anchors.bottom: root.bottom
        anchors.left:   root.left
        anchors.right:  root.right

        anchors.bottomMargin: 5
        anchors.leftMargin:   5

        height: 1
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: "IBeamCursor"
        onClicked: input.focus = true
    }
}
