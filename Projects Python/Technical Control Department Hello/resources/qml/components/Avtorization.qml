import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    anchors.fill: parent
    color: "#282e33"

    Rectangle {
        id: blockAvt
        width:  360
        height: 460

        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 15
        color: "#313840"

        border.width: 1
        border.color: "white"

        Image {
            id: iconApp
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            width:  135
            height: 135

            source: "../../images/chemistry.png"
        }

        Label {
            id: labelAvt

            anchors.top: iconApp.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 16
            font.bold: true
            color: "white"

            text: "Авторизация"
        }

        Input {
            id: login

            width: 250
            placeholder: "Ваш логин"

            anchors.top: labelAvt.bottom
            anchors.left: parent.left

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        Input {
            id: password

            width: 250
            placeholder: "Ваш пароль"

            anchors.top: login.bottom
            anchors.left: parent.left

            anchors.topMargin: 20
            anchors.leftMargin: 50
        }

        EnterButton {
            id: enterInSystem

            textButton: "Войти в систему"

            width:  120;

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                if(login.getText() !== "" && password.getText() !== "") {
                    database.avt(login.getText(), password.getText())
                    login.clear(); password.clear()
                }
            }
        }
    }
}
