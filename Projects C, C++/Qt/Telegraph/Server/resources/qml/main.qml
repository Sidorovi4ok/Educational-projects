import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    width:  360
    height: 550

    minimumWidth:  360
    minimumHeight: 550

    maximumWidth:  360
    maximumHeight: 550

    visible: true
    color: "#282e33"
    title: qsTr("Server")

    property bool statusServer: false

    Connections {
        target: root

        function onClosing(close) {
            close.accepted = false
            mainWindow.closeEvent()
            close.accepted = true
        }
    }

    Connections {
        target: mainWindow

        function onConsoleMessageQml(message) {
            consoleLog.append(message)
        }

        function onOpenedQml() {
            openServer.text = qsTr("Закрыть сервер")
            openServer.checked = true
            root.statusServer = true
        }

        function onClosedQml() {
            openServer.text = qsTr("Открыть сервер")
            openServer.checked = false
            root.statusServer = false
        }
    }

    Rectangle {
        id: header

        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right

        height: 40
        color: "#313840"

        Label {
            anchors.left:   parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 25

            font.pointSize: 15
            color: "white"

            text: qsTr("Сервер")
        }

        Rectangle {
            id: rectIndicator

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 30

            width: 12; height: width
            radius: height / 2
            color: root.statusServer ? "lightgreen" : "red"

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }

    Rectangle {
        id: content

        anchors.top:    header.bottom
        anchors.bottom: footer.top
        anchors.left:   parent.left
        anchors.right:  parent.right

        anchors.topMargin: 10
        anchors.bottomMargin: 10

        color: "#313840"

        Rectangle {
            id: blockData

            anchors.top:    parent.top
            anchors.left:   parent.left
            anchors.right:  parent.right

            anchors.topMargin:   10
            anchors.leftMargin:  10
            anchors.rightMargin: 10

            height: 100
            radius: 15
            color: "#282e33"

            Rectangle {
                id: port

                anchors.top:   parent.top
                anchors.left:  parent.left
                anchors.right: parent.right

                anchors.topMargin:   5
                anchors.leftMargin:  35
                anchors.rightMargin: 35

                height: 40

                color: "transparent"

                Button {
                    id: iconPort
                    enabled: false
                    flat: true

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5

                    icon.width: 20
                    icon.height: 20
                    icon.color: "white"
                    icon.source: "../../icons/ethernet.png"

                    background: Rectangle {
                        opacity: 0
                    }
                }

                TextInput {
                    id: inputPort

                    anchors.left:           iconPort.right
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    enabled: !root.statusServer

                    anchors.leftMargin: 8

                    focus: true
                    clip: true

                    font.pointSize: 10
                    color: (!root.statusServer) ? "white" : "#AAAAAA"

                    Label {
                        id: inputTextPort
                        anchors.fill: parent

                        elide: Text.ElideRight
                        opacity: (parent.text !== "") ? 0 : 0.6

                        font.pointSize: inputPort.font.pointSize
                        color: "#AAAAAA"
                        text: qsTr("Порт сервера")
                    }
                }

                Rectangle {
                    anchors.bottom: port.bottom
                    anchors.left:   port.left
                    anchors.right:  port.right

                    anchors.bottomMargin: 5
                    anchors.leftMargin:   5

                    height: 1
                    color: "white"
                }
            }

            Rectangle {
                id: keyword

                anchors.top:   port.bottom
                anchors.left:  parent.left
                anchors.right: parent.right

                anchors.topMargin:   5
                anchors.leftMargin:  35
                anchors.rightMargin: 35

                height: 40

                color: "transparent"

                Button {
                    id: iconKeyword
                    enabled: false
                    flat: true

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5

                    icon.width: 20
                    icon.height: 20
                    icon.color: "white"
                    icon.source: "../../icons/keyword.png"

                    background: Rectangle {
                        opacity: 0
                    }
                }

                TextInput {
                    id: inputKeyword

                    anchors.left:           iconKeyword.right
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    enabled: !root.statusServer

                    anchors.leftMargin: 8

                    focus: true
                    clip: true

                    font.pointSize: 10
                    color: (!root.statusServer) ? "white" : "#AAAAAA"

                    Label {
                        id: inputTextKeyword
                        anchors.fill: parent

                        elide: Text.ElideRight
                        opacity: (parent.text !== "") ? 0 : 0.6

                        font.pointSize: inputKeyword.font.pointSize
                        color: "#AAAAAA"
                        text: qsTr("Кодовое слово для подключения к серверу")
                    }
                }

                Rectangle {
                    anchors.bottom: keyword.bottom
                    anchors.left:   keyword.left
                    anchors.right:  keyword.right

                    anchors.bottomMargin: 5
                    anchors.leftMargin:   5

                    height: 1
                    color: "white"
                }
            }
        }

        Rectangle {
            id: blockConsole

            anchors.top:    blockData.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right

            anchors.topMargin:   10
            anchors.leftMargin:  10
            anchors.rightMargin: 10

            height: 250
            radius: 15
            color: "#282e33"

            Label {
                id: labelConsole

                anchors.left: parent.left
                anchors.top:  parent.top

                anchors.leftMargin: 15
                anchors.topMargin:  15

                font.pointSize: 10
                color: "white"

                text: qsTr("Консоль:")
            }

            ScrollView {
                id: scrollConsole

                anchors.top:    labelConsole.bottom
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
                anchors.right:  parent.right

                anchors.margins: 10

                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                TextArea {
                    id: consoleLog

                    font.italic: true
                    font.pointSize: 9
                    color: "white"

                    background: Rectangle {
                        radius: 15
                        color: "transparent"
                    }
                }
            }
        }

        Button {
            id: openServer

            anchors.top: blockConsole.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20

            width:  250;
            height: 40
            flat: true
            checkable : true

            enabled: (inputKeyword.text !== "" && inputPort.text !== "")

            text: qsTr("Открыть сервер")

            background: Rectangle {
                radius: 10
                color: "#4f92c9"
            }

            contentItem: Label {
                color: "white"
                font.pointSize: 11
                text: parent.text
                verticalAlignment:   Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    if (!openServer.checked && inputPort.text !== "" && inputKeyword.text !== "") {
                        mainWindow.open(inputPort.text, inputKeyword.text)
                    } else if (openServer.checked) {
                        mainWindow.close()
                    }
                }
            }
        }
    }

    Rectangle {
        id: footer

        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right

        height: 40
        color: "#313840"

        Label {
            anchors.left:   parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 25

            font.pointSize: 8
            color: "#AAAAAA"

            text: qsTr("Версия: 0.2")
        }
    }
}
