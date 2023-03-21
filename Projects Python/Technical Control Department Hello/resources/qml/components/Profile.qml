import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    visible: false
    anchors.fill: parent
    color: "#282e33"

    // Сигнал, что пользователь вышел из аккаунта
    signal exitAccount()

    // Данные пользователя для отображения в интерфейсе
    property string nameWorker: ""
    property string fioWorker : ""
    property int    roleWorker: 0

    // Кнопка для открытия бокового меню
    Rectangle {
        id: iconUserBlock

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15

        width: 40; height: width
        radius: height / 2

        Button {
            id: iconUser

            anchors.fill: parent
            anchors.margins: 5
            flat: true

            icon.width: 40
            icon.height: 40
            icon.color: "transparent"
            icon.source: "../../icons/user.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    menuUser.open()
                }
            }
        }
    }

    Label {
        id: labelPersonalProfile

        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: 16
        font.bold: true
        color: "white"
        text: "Личный кабинет"
    }

    // Боковое меню с информацией пользователя
    Drawer {
        id: menuUser

        modal: true
        enabled: profile.visible
        interactive: (profile.visible) ? true : false

        width: 250
        height: parent.height
        visible: false

        contentItem: Rectangle {
            anchors.fill: parent
            color: "#282e33"
        }

        Rectangle {
            id: menuUserHeader

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: 95
            color: "#313840"

            Label {
                id: menuUserLogin

                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 15

                color: "white"
                font.pointSize: 10
                font.italic: true

                text: "Логин: " + root.nameWorker
            }

            Label {
                id: menuUserFio

                anchors.top: menuUserLogin.bottom
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 15

                color: "white"
                font.pointSize: 10
                font.italic: true

                text: "Фио: " + root.fioWorker
            }

            Label {
                    id: menuUserRole

                    anchors.top: menuUserFio.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    color: "white"
                    font.pointSize: 10
                    font.italic: true

                    text: "Роль: " + ((root.roleWorker === 1) ? "Начальник"     :
                                      (root.roleWorker === 2) ? "Контролер"     :
                                      (root.roleWorker === 3) ? "Лаборант"      : "Менеджер по работе с клиентами")
                }
        }

        Rectangle {
            id: menuUserBody

            anchors.fill: parent
            anchors.topMargin: menuUserHeader.height + 5
            color: "#282e33"

            Rectangle {
                id: menuUserBodyExit

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.margins: 5

                height: 35
                radius: 8
                color: "#313840"

                border.color: "#AAAAAA"
                border.width: 1

                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: qsTr("Выйти из аккаунта")
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        menuUser.close()
                        root.exitAccount()
                    }
                }
            }
        }
    }

    // Граница между надписью "Линый кабинет" и контентом
    Rectangle {
        anchors.top:   iconUserBlock.bottom
        anchors.left:  root.left
        anchors.right: root.right

        anchors.topMargin:   15
        anchors.leftMargin:  10
        anchors.rightMargin: 10

        height: 1
        color: "white"
    }

    // Если роль пользователя директор
    Director {
        id: pageDirector
        visible: (roleWorker === 1) ? true : false

        nameWorker: root.nameWorker

        anchors.top: labelPersonalProfile.bottom
        anchors.topMargin: 75
    }

    // Если роль пользователя лаборант
    Laborant {
        id: pageLaborant
        visible: (roleWorker === 3) ? true : false

        anchors.top: labelPersonalProfile.bottom
        anchors.topMargin: 75
    }

    // Если роль пользователя контролер
    Сontroller {
        id: pageController
        visible: (roleWorker === 2) ? true : false

        anchors.top: labelPersonalProfile.bottom
        anchors.topMargin: 75
    }
}
