import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    visible: false
    anchors.fill: parent
    color: parent.color

    Connections {
        target: database

        function onLoadedClients(name, phone, email) {
            clients.append({"name": name, "phone": phone, "email": email})
        }

        function onLoadedService(name, price) {
            services.append({"name": name, "price": price})
        }
    }

    // Блок для открытия страницы с информацией о клиентах
    Rectangle {
        id: openModelClients

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
            text: "Открыть базу клиентов ОТК"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                clients.clear()
                database.loadClients()
                blockClients.visible = true
            }
        }
    }

    // Блок для открытия страницы с информацией о услугах
    Rectangle {
        id: openModelServices

        anchors.left:  parent.left
        anchors.top:   openModelClients.bottom
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

    // Блок для открытия страницы с добавлением нвоого заказа
    Rectangle {
        id: openApendBlockOrder

        anchors.left:  parent.left
        anchors.top:   openModelServices.bottom
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
            text: "Сформулировать новый заказ"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                blockAddOrder.visible = true
            }
        }
    }

// -------------------------------------------------------------------------------------

    // Показ моедли клиентов
    Rectangle {
        id: blockClients

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
            text: "База данных клиентов ОТК"
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
                    blockClients.visible = false
                }
            }
        }

        ListModel {
            id: clients
        }

        ListView {
            id: viewClients

            anchors.fill: parent
            model: clients
            spacing: 8

            anchors.topMargin: 70
            anchors.bottomMargin: 50

            delegate: Rectangle {
                id: delegateClient

                height: 40
                radius: 5
                color: "#313840"

                Label {
                    id: nameClient

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Имя: " + name
                }

                Label {
                    id: phoneClient

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: nameClient.right
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Номер телефона: " + phone
                }

                Label {
                    id: emailClient

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: phoneClient.right
                    anchors.leftMargin: 15

                    font.pointSize: 10
                    color: "white"

                    text: "Електронная почта: " + email
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

    // Показ моедли услуг
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

    // Показ блока с добавлением нoвого заказа
    Rectangle {
        id: blockAddOrder

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            id: labelNewOrder

            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Оформление нового заказа"
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
                    blockAddOrder.visible = false
                }
            }
        }

        Input {
            id: inputSosud
            width: 250
            placeholder: "Введите номер лабораторного материала"

            anchors.top: labelNewOrder.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        Input {
            id: inputService
            width: 250
            placeholder: "Введите название услуги"

            anchors.top: inputSosud.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        Input {
            id: inputClient
            width: 250
            placeholder: "Введите имя клиента"

            anchors.top: inputService.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        EnterButton {
            id: createOrder

            textButton: "Сформировать заказ"

            width:  200;

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                if(inputSosud.getText() !== "" && inputService.getText() !== "" && inputClient.getText() !== "") {
                    database.appendOrder(inputSosud.getText(), inputService.getText(), inputClient.getText())
                    inputSosud.clear()
                    inputService.clear()
                    inputClient.clear()
                }
            }
        }

        Button {
            id: createClientButton

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            width:  createClientButton.text.width;
            height: createClientButton.text.height
            flat: true

            text: qsTr("Создать нового клиента")

            background: Rectangle {
                opacity: 0
            }

            contentItem: Label {
                color: "#579ed9"
                text: createClientButton.text
                font.underline: true
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockAddUser.visible = true
                }
            }
        }
    }

    // Показ блока с добавлением нoвого клиента
    Rectangle {
        id: blockAddUser

        visible: false
        anchors.fill: parent
        color: "#282e33"

        Label {
            id: labelNewUser

            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Добавление нового клиента"
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
                    blockAddUser.visible = false
                }
            }
        }

        Input {
            id: inputFioClient

            width: 250
            placeholder: "Введите имя заказчика"

            anchors.top: labelNewUser.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        Input {
            id: inputPhoneClient

            width: 250
            placeholder: "Введите номер телефона клиента"

            anchors.top: inputFioClient.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        Input {
            id: inputEmailClient

            width: 250
            placeholder: "Введите эл.почту клиента"

            anchors.top: inputPhoneClient.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: 20
            anchors.leftMargin: 50
            anchors.rightMargin: 50
        }

        EnterButton {
            id: createNewClient

            textButton: "Добавить клиента"

            width:  200;

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                if(inputFioClient.getText() !== "" && inputPhoneClient.getText() !== "" && inputEmailClient.getText() !== "") {
                    database.appendClient(inputFioClient.getText(),
                                          inputPhoneClient.getText(),
                                          inputEmailClient.getText())
                    inputFioClient.clear()
                    inputPhoneClient.clear()
                    inputEmailClient.clear()
                }
            }
        }
    }
}
