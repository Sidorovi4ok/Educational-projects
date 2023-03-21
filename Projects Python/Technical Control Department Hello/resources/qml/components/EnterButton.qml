import QtQuick

Rectangle {
    id: root

    property string textButton: ""
    signal clicked

    height: 30
    radius: 12
    color: "#4f92c9"

    Text {
        id: label
        anchors.centerIn: parent

        color: "white"
        font.pointSize: 10

        text: root.textButton
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: "PointingHandCursor"
        onClicked: root.clicked()
    }
}
