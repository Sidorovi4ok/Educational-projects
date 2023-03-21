import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    visible: false
    anchors.fill: parent
    color: parent.color

    Connections {
        target: database

        function onLoadedOrder(time, service, price, client, sosud, worker, status) {
            orders.append({"number": sosud, "price" : price,
                           "time"  : time,  "client": client,
                           "status": status
                          })
        }

        function onClearOrders() {
            orders.clear()
        }
    }

    // Блок для открытия страницы с информацией о заказах
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 10

        height: 40
        color: "#313840"

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 12
            font.bold: true
            color: "white"
            text: "Открыть базу заказов в системе"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                orders.clear()
                database.loadOrders()
                blockOrders.visible = true
            }
        }
    }

//--------------------------------------------------------------------------------------

    Rectangle {
        id: blockOrders

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
            text: "Просмотр существующих заказов"
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
                    blockOrders.visible = false
                }
            }
        }

        ListModel {
            id: orders
        }

        ListView {
            id: viewOrders

            anchors.fill: parent
            model: orders
            spacing: 8

            anchors.topMargin: 70
            anchors.bottomMargin: 50

            delegate: Rectangle {
                id: delegateOrders

                height: (status === "В процессе проверки") ? 60 : 40
                radius: 5

                color: "#313840"

                Label {
                    id: numberOrders

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.leftMargin: 10

                    font.pointSize: 10
                    color: "white"

                    text: "Id сосуда: " + number
                }

                Label {
                    id: priceOrders

                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: numberOrders.right
                    anchors.leftMargin: 10

                    font.pointSize: 10
                    color: "white"

                    text: "Цена: " +price
                }

                Label {
                    id: timeOrders

                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: priceOrders.right
                    anchors.leftMargin: 10

                    font.pointSize: 10
                    color: "white"

                    text: "Время: " + time
                }

                Label {
                    id: clientOrders

                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: timeOrders.right
                    anchors.leftMargin: 10

                    font.pointSize: 10
                    color: "white"

                    text: "Клиент: " +client
                }

                Label {
                    id: statusOrder

                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: clientOrders.right
                    anchors.leftMargin: 10

                    font.pointSize: 10
                    color: "white"

                    text: status
                }

                Button {
                    id: trueOrder

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.bottomMargin: 8
                    anchors.leftMargin: 15

                    flat: true
                    height: 17
                    width: 75

                    visible: (status === "В процессе проверки") ? true : false
                    text: "Успешно"

                    background: Rectangle {
                        color: "#4f92c9"
                        radius: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {
                            database.confirmOrder(number)
                        }
                    }
                }

                Button {
                    anchors.bottom: parent.bottom
                    anchors.left: trueOrder.right
                    anchors.bottomMargin: 8
                    anchors.leftMargin: 15

                    flat: true
                    height: 17
                    width: 75

                    visible: (status === "В процессе проверки") ? true : false
                    text: "Провал"

                    background: Rectangle {
                        color: "#4f92c9"
                        radius: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {
                            database.cancelOrder(number)
                        }
                    }
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
}
