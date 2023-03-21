import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    anchors.fill: parent
    color: "#282e33"

    signal open()
    signal close()

    Connections {
        target: root
        function onOpen() {
            seqAni_open.start()
        }
    }

    Image {
        id: imageWelcome
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right

        height: 215

        //source: ":/images/welcome.png"
        source: "../../images/welcome.png"
    }

    SwipeView {
        id: viewWelcome

        anchors.top:    imageWelcome.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        currentIndex: 0

        Rectangle {
            color: root.color

            Label {
                id: nameApp

                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.horizontalCenter: parent.horizontalCenter

                font.pointSize: 17

                color: "white"
                text: "Telegraph Desktop"
            }

            Label {
                id: label_block_1_1

                anchors.top: nameApp.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter

                font.italic: true
                font.pointSize: 11
                color: "#AAAAAA"

                text: "Добро пожаловать в Telegraph для ПК."
            }

            Label {
                id: label_block_1_2

                anchors.top: label_block_1_1.bottom
                anchors.topMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter

                font.italic: true
                font.pointSize: 11
                color: "#AAAAAA"

                text: "Быстрый и безопасный официальный клиент."
            }
        }

        Rectangle {
            color: root.color

            Label {
                id: label_block_2_1

                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.horizontalCenter: parent.horizontalCenter

                font.pointSize: 17
                color: "white"

                text: "Практичный"
            }

            Label {
                id: label_block_2_2

                anchors.top: label_block_2_1.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter

                font.italic: true
                font.pointSize: 11
                color: "#AAAAAA"

                text: "Общайтесь с кем угодно и когда угодно."
            }
        }

        Rectangle {
            color: root.color

            Label {
                id: label_block_3_1

                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.horizontalCenter: parent.horizontalCenter

                font.pointSize: 17
                color: "white"

                text: "Бесплатный"
            }

            Label {
                id: label_block_3_2

                anchors.top: label_block_3_1.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter

                font.italic: true
                font.pointSize: 11
                color: "#AAAAAA"

                text: "Ваще общение больше ничего не ограничивает."
            }
        }

        Rectangle {
            color: root.color

            Label {
                id: label_block_4_1

                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.horizontalCenter: parent.horizontalCenter

                font.pointSize: 17
                color: "white"

                text: "Безопасный"
            }

            Label {
                anchors.top: label_block_4_1.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter

                font.italic: true
                font.pointSize: 11
                color: "#AAAAAA"

                text: "Мы не передаём ваши данные третьим лицам."
            }
        }
    }

    Button {
        id: buttonGoToAvt

        anchors.bottom: pageIndicator.top
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        width:  300;
        height: 40
        flat: true

        text: qsTr("Начать общение")

        background: Rectangle {
            radius: 10
            color: "#4f92c9"
        }

        contentItem: Label {
            color: "white"
            font.pointSize: 11
            text: buttonGoToAvt.text
            verticalAlignment:   Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                root.close();
                seqAni_close.start();
            }
        }
    }

    Button {
        id: buttonSwitchLanguage

        anchors.top: buttonGoToAvt.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        width:  buttonSwitchLanguage.text.width;
        height: buttonSwitchLanguage.text.height
        flat: true

        text: qsTr("Continue in English")


        background: Rectangle {
            opacity: 0
        }

        contentItem: Label {
            color: "#579ed9"
            text: buttonSwitchLanguage.text
            font.underline: true
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {

            }
        }
    }

    PageIndicator {
        id: pageIndicator

        count: viewWelcome.count
        currentIndex: viewWelcome.currentIndex

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5

        delegate: Rectangle {
            id: indicator
            implicitHeight: 6
            implicitWidth: 6

            radius: width / 2
            color: "#AAAAAA"

            opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

            Behavior on opacity {
                OpacityAnimator {
                    duration: 200
                }
            }
        }
    }

    ParallelAnimation {
        id: seqAni_close

        NumberAnimation {
            target: imageWelcome
            properties: "anchors.topMargin"
            to: -250
            duration: 390
        }

        NumberAnimation {
            target: imageWelcome
            properties: "visible"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "visible"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "opacity"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "scale"
            to: 0.5
            duration: 390
        }

        NumberAnimation {
            target: buttonGoToAvt
            properties: "anchors.bottomMargin"
            to: -250
            duration: 390
        }

        NumberAnimation {
            target: buttonGoToAvt
            properties: "visible"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: buttonSwitchLanguage
            properties: "visible"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: pageIndicator
            properties: "anchors.bottomMargin"
            to: -100
            duration: 390
        }

        NumberAnimation {
            target: root
            properties: "visible"
            to: 0
            duration: 400
        }

        NumberAnimation {
            target: root
            properties: "scale"
            to: 3
            duration: 600
        }
    }

    ParallelAnimation {
        id: seqAni_open

        NumberAnimation {
            target: imageWelcome
            properties: "anchors.topMargin"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: imageWelcome
            properties: "visible"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "visible"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "opacity"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: viewWelcome
            properties: "scale"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: buttonGoToAvt
            properties: "anchors.bottomMargin"
            to: 50
            duration: 390
        }

        NumberAnimation {
            target: buttonGoToAvt
            properties: "visible"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: buttonSwitchLanguage
            properties: "visible"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: pageIndicator
            properties: "anchors.bottomMargin"
            to: 5
            duration: 390
        }

        NumberAnimation {
            target: root
            properties: "visible"
            to: 1
            duration: 390
        }

        NumberAnimation {
            target: root
            properties: "scale"
            to: 1
            duration: 400
        }
    }
}
