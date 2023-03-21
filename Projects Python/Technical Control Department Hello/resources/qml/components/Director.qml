import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    visible: false
    anchors.fill: parent
    color: parent.color

    property string nameWorker: ""

    Connections {
        target: database

        function onLoadedWorker(login, fio, role) {
            if (login !== root.nameWorker)
                workers.append({"login": login, "fio": fio, "role": role})
        }

        function onLoadedService(name, price) {
            services.append({"name": name, "price": price})
        }
    }

    Rectangle {
        id: openModelWorkers

        anchors.left:  parent.left
        anchors.top:   parent.top
        anchors.right: parent.right

        anchors.leftMargin:  15
        anchors.rightMargin: 15
        anchors.topMargin:   10

        height: 40
        color: "#313840"

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Открыть базу сотрудников ОТК"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                workers.clear()
                database.loadWorkers()
                blockWorkers.visible = true
            }
        }
    }

    // Блок для открытия страницы с информацией о услугах
    Rectangle {
        id: openModelServices

        anchors.left:  parent.left
        anchors.top:   openModelWorkers.bottom
        anchors.right: parent.right

        anchors.leftMargin:  15
        anchors.rightMargin: 15
        anchors.topMargin:   10

        height: 40
        color: "#313840"

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Просмотр доступных услуг ОТК"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                services.clear()
                database.loadServices()
                blockServices.visible = true
            }
        }
    }

//------------------------------------------------------------------------------------------------------------
    // Отображение модели сотрудников
    Rectangle {
        id: blockWorkers

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "База данных сотрудников ОТК"
        }

        Button {
            flat: true
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/back.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockWorkers.visible = false
                }
            }
        }

        Button {
            flat: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 15

            icon.width: 25
            icon.height: 25
            icon.color: "#AAAAAA"
            icon.source: "../../icons/add.png"

            background: Rectangle {
                opacity: 0
                radius: width * 0.5
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockAddNewWorker.visible = true
                    blockWorkers.visible = false
                }
            }
        }

        ListModel {
            id: workers
        }

        ListView {
            id: viewWorkers

            anchors.fill: parent
            model: workers
            spacing: 8

            anchors.topMargin: 70
            anchors.bottomMargin: 50

            delegate: Rectangle {
                id: myDelegate

                height: 40
                radius: 5

                color: "#313840"

                Label {
                    id: loginWorker
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Логин: " + login
                }

                Label {
                    id: fioWorker

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: loginWorker.right
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "ФИО: " + fio
                }

                Label {
                    id: roleWorker

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: fioWorker.right
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: ((role === 1)  ? "Начальник"     :
                           (role  === 2) ? "Администратор" :
                           (role  === 3) ? "Лаборант"      : "Менеджер по работе с клиентами")
                }

                Component.onCompleted: {
                    anchors.left  = parent.left
                    anchors.right = parent.right
                    anchors.leftMargin  = 25
                    anchors.rightMargin = 25
                }
            }
        }
    }

    // Отображение блока для добавления нового сотрудника
    Rectangle {
        id: blockAddNewWorker

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            id: labelNewWorker

            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Регистрация нового сотрудника"
        }

        Button {
            flat: true
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/back.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    workers.clear()
                    database.loadWorkers()
                    blockAddNewWorker.visible = false
                    blockWorkers.visible = true
                }
            }
        }

        Input {
            id: newLogin

            width: 250
            placeholder: "Логин сотрудника"

            anchors.top: labelNewWorker.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        Input {
            id: newFio

            width: 250
            placeholder: "ФИО сотрудника"

            anchors.top: newLogin.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        Input {
            id: newPassword

            width: 250
            placeholder: "Пароль от аккаунта сотрудника"

            anchors.top: newFio.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        Input {
            id: newRole

            width: 250
            placeholder: "Занимающая должность сотрудника"

            anchors.top: newPassword.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        EnterButton {
            id: addNewWorker

            textButton: "Добавить нового сотрудника"

            width:  200;

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                if(newLogin.getText()    !== "" && newFio.getText()  !== "" &&
                   newPassword.getText() !== "" && newRole.getText() !== "")
                {
                    database.appendWorker(newLogin.getText(),
                                          newFio.getText(),
                                          newPassword.getText(),
                                          newRole.getText())
                    newLogin.clear(); newFio.clear();
                    newPassword.clear(); newRole.clear()
                }
            }
        }
    }

    // Отображение модели услуг
    Rectangle {
        id: blockServices

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Доступные услуги ОТК"
        }

        Button {
            flat: true
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/back.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockServices.visible = false
                }
            }
        }

        Button {
            flat: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 15

            icon.width: 25
            icon.height: 25
            icon.color: "#AAAAAA"
            icon.source: "../../icons/add.png"

            background: Rectangle {
                opacity: 0
                radius: width * 0.5
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockAddNewService.visible = true
                    blockServices.visible = false
                }
            }
        }

        ListModel {
            id: services
        }

        ListView {
            id: viewServices

            anchors.fill: parent
            model: services
            spacing: 8

            anchors.topMargin: 70
            anchors.bottomMargin: 50

            delegate: Rectangle {
                id: delegateServices

                height: 40
                radius: 5

                color: "#313840"

                Label {
                    id: nameService

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Название: " + name
                }

                Label {
                    id: priceService

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: nameService.right
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Цена услуги: " + price
                }

                Component.onCompleted: {
                    anchors.left  = parent.left
                    anchors.right = parent.right

                    anchors.leftMargin  = 25
                    anchors.rightMargin = 25
                }
            }
        }
    }

    Rectangle {
        id: blockAddNewService

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            id: labelNewService

            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Регистрация новой услуги ОТК"
        }

        Button {
            flat: true
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/back.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    services.clear()
                    database.loadServices()
                    blockAddNewService.visible = false
                    blockServices.visible = true
                }
            }
        }

        Input {
            id: newNameService

            width: 250
            placeholder: "Название услуги"

            anchors.top: labelNewService.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        Input {
            id: newPrice

            width: 250
            placeholder: "Цена предоставляемой услуги"

            anchors.top: newNameService.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        EnterButton {
            id: addNewService

            textButton: "Добавить новую услугу"

            width:  200;

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                if(newNameService.getText() !== "" && newPrice.getText()  !== "")
                {
                    database.appendService(newNameService.getText(),
                                           newPrice.getText())
                    newNameService.clear()
                    newPrice.clear()
                }
            }
        }
    }
}
