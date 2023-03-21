import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: "#282e33"
    visible: false

    signal open()
    signal close()
    signal loginUser()
    signal viewNotification(title: string, discription: string)

    property bool statusJoined: false

    Connections {
        target: mainWindow

        function onJoinedServer() {            
            root.statusJoined = true
        }

        function onExitServer() {
            root.statusJoined = false
            connectButton.checked = false
        }

        function onAvtSuccess() {
            root.loginUser();
            seqAni_close.start();
        }

        function onRegSuccess() {
            root.viewNotification("Регистрация", "Вы успешно зарегистрировались.")
            seqAni_reg_close.start()
        }

        function onAvtError(title, message) {
            root.viewNotification(title, message)
        }
    }

    Connections {
        target: root

        function onOpen() {
            seqAni_open.start()
        }
    }

    Popup {
        id: settingWindow
        parent: Overlay.overlay

        modal: true
        focus: true
        padding: 3

        x: Math.round((parent.width  - width) / 2)
        y: Math.round((parent.height - height) / 2)

        width: 380
        height: 480

        Rectangle {
           color: "transparent";
           anchors.fill: parent

            ColumnLayout {
               anchors.fill: parent
               spacing: 10

               Rectangle {
                   height: 50
                   Layout.fillWidth: true
                   radius: 12
                   color: "#282e33"

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.verticalCenter: parent.verticalCenter

                        color: "#AAAAAA"
                        font.pointSize: 13
                        font.bold: true

                        text: qsTr("Настройки:")
                    }

                    Button {
                        anchors.right: parent.right
                        anchors.rightMargin: 25
                        anchors.verticalCenter: parent.verticalCenter

                        flat: true

                        icon.width: 12
                        icon.height: 12
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/close.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                settingWindow.close()
                            }
                        }
                    }
                }

               Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#282e33"

                    Label {
                       id: portLabel

                       anchors.verticalCenter: parent.verticalCenter
                       anchors.left: parent.left
                       anchors.leftMargin: 10

                       font.pointSize: 12
                       color: "#AAAAAA"

                       text: qsTr("Сервер:")
                    }

                    Rectangle {
                       id: address

                       anchors.left:  portLabel.right
                       anchors.right: connectButton.right
                       anchors.verticalCenter: parent.verticalCenter

                       anchors.leftMargin:  15
                       anchors.rightMargin: 50

                       height: 40
                       color: "transparent"

                       TextInput {
                           id: inputAddress

                           anchors.left:  parent.left
                           anchors.right: parent.right
                           anchors.bottom: parent.bottom

                           anchors.leftMargin:  8
                           anchors.bottomMargin: 15

                           enabled: !root.statusJoined

                           font.pointSize: 10
                           color: (root.statusJoined) ? "#AAAAAA" : "white"

                           text: "ws://localhost:10000"

                           Label {
                               id: inputAddressName
                               anchors.fill: parent

                               elide: Text.ElideRight
                               opacity: (parent.text !== "") ? 0 : 0.6

                               font.pointSize: inputAddress.font.pointSize
                               color: "#AAAAAA"
                               text: qsTr("Адрес сервера")
                           }
                       }

                       Rectangle {
                           anchors.bottom: address.bottom
                           anchors.left:   address.left
                           anchors.right:  address.right

                           anchors.bottomMargin: 5
                           anchors.leftMargin:   5

                           height: 1
                           color: "white"
                        }
                    }

                    Button {
                        id: connectButton

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 15

                        checkable: true
                        flat: true

                        icon.width:  20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/link.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                if (!connectButton.checked && inputAddress.text != "") {
                                    connectButton.checked = true
                                    mainWindow.connect(inputAddress.text)
                                }
                                else if(connectButton.checked) {
                                    connectButton.checked = false
                                    mainWindow.disconnect()
                                }
                            }
                        }
                    }
                }

               Item { Layout.fillHeight: true }
            }
        }

        background: Rectangle {
            color: "#313840"
            radius: 15

            border.width: 2
            border.color: "#AAAAAA"
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0;
                duration: 200
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0
                to: 0.0;
                duration: 200
            }
        }
    }

    Rectangle {
        id: blockAvt
        width:  360
        height: 460

        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#313840"
        radius: 15

        border.width: 1
        border.color: "white"

        Image {
            id: iconApp
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            width:  100
            height: 100

            source: "../../images/telegram.png"
        }

        Label {
            id: labelAvt

            anchors.top: iconApp.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            font.pointSize: 15
            color: "white"

            text: qsTr("Авторизация")
        }

        Rectangle {
            id: name

            anchors.top: labelAvt.bottom
            anchors.left:  parent.left
            anchors.right: parent.right

            anchors.topMargin:   5
            anchors.leftMargin:  35
            anchors.rightMargin: 35

            height: 40

            color: "transparent"

            Button {
                id: iconNameuser
                enabled: false
                flat: true

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5

                icon.width: 20
                icon.height: 20
                icon.color: "#AAAAAA"
                icon.source: "../../icons/user.png"

                background: Rectangle {
                    opacity: 0
                }
            }

            TextInput {
                id: inputName

                anchors.left: iconNameuser.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                anchors.leftMargin: 8

                focus: true
                clip: true

                font.pointSize: 10
                color: "white"

                Label {
                    id: inputTextName
                    anchors.fill: parent

                    elide: Text.ElideRight
                    opacity: (parent.text !== "") ? 0 : 0.6

                    font.pointSize: inputName.font.pointSize
                    color: "#AAAAAA"
                    text: qsTr("Имя пользователя")
                }
            }

            Rectangle {
                anchors.bottom: name.bottom
                anchors.left:   name.left
                anchors.right:  name.right

                anchors.bottomMargin: 5
                anchors.leftMargin:   5

                height: 1
                color: "white"
            }
        }

        Rectangle {
            id: password

            anchors.top: name.bottom
            anchors.left:  parent.left
            anchors.right: parent.right

            anchors.topMargin:   10
            anchors.leftMargin:  35
            anchors.rightMargin: 35

            height: 40

            color: "transparent"

            Button {
                id: iconPassword
                enabled: false
                flat: true

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5

                icon.width: 20
                icon.height: 20
                icon.color: "#AAAAAA"
                icon.source: "../../icons/padlock.png"

                background: Rectangle {
                    opacity: 0
                }
            }

            TextInput {
                id: inputPassword

                anchors.left: iconPassword.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                anchors.leftMargin: 8

                focus: true
                clip: true
                echoMode: TextInput.Password

                font.pointSize: 10
                color: "white"

                Label {
                    id: inputTextPassword
                    anchors.fill: parent

                    elide: Text.ElideRight
                    opacity: (parent.text !== "") ? 0 : 0.6

                    font.pointSize: inputPassword.font.pointSize
                    color: "#AAAAAA"
                    text: qsTr("Пароль")
                }
            }

            Button {
                id: showPassword

                anchors.verticalCenter: password.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 5

                flat: true

                icon.width:  18
                icon.height: 18
                icon.color: "#AAAAAA"
                icon.source: "../../icons/eyeClose.png"

                background: Rectangle {
                    opacity: 0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        if (inputPassword.echoMode === TextInput.Password) {
                            inputPassword.echoMode = TextInput.Normal
                            showPassword.icon.source    = "../../icons/eyeOpen.png"
                        }
                        else {
                            showPassword.icon.source    = "../../icons/eyeClose.png"
                            inputPassword.echoMode = TextInput.Password
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: password.bottom
                anchors.left:   password.left
                anchors.right:  password.right

                anchors.bottomMargin: 5
                anchors.leftMargin:   5

                height: 1
                color: "white"
            }
        }

        Rectangle {
            id: keyword
            anchors.top: password.bottom
            anchors.left:  parent.left
            anchors.right: parent.right

            anchors.topMargin:   10
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
                icon.color: "#AAAAAA"
                icon.source: "../../icons/keyword.png"

                background: Rectangle {
                    opacity: 0
                }
            }

            TextInput {
                id: inputKeyword

                anchors.left: iconKeyword.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                anchors.leftMargin: 8

                focus: true
                clip: true
                echoMode: TextInput.Password

                font.pointSize: 10
                color: "white"

                Label {
                    id: inputTextKeyword
                    anchors.fill: parent

                    elide: Text.ElideRight
                    opacity: (parent.text !== "") ? 0 : 0.6

                    font.pointSize: inputKeyword.font.pointSize
                    color: "#AAAAAA"
                    text: qsTr("Кодовое слово от сервера")
                }
            }

            Button {
                id: showKeyword

                anchors.verticalCenter: keyword.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 5

                flat: true

                icon.width:  18
                icon.height: 18
                icon.color: "#AAAAAA"
                icon.source: "../../icons/eyeClose.png"

                background: Rectangle {
                    opacity: 0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"

                    onClicked: {
                        if (inputKeyword.echoMode === TextInput.Password) {
                            inputKeyword.echoMode   = TextInput.Normal
                            showKeyword.icon.source = "../../icons/eyeOpen.png"
                        }
                        else {
                            inputKeyword.echoMode   = TextInput.Password
                            showKeyword.icon.source = "../../icons/eyeClose.png"
                        }
                    }
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

        CheckBox {
            id: remeber

            anchors.top: keyword.bottom
            anchors.left: parent.left
            anchors.topMargin: 10
            anchors.leftMargin: 50

            checked: false
            text: qsTr("Запомнить меня")

            contentItem: Label {
                color: "#AAAAAA"
                text: remeber.text
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    remeber.checked = !remeber.checked
                }
            }
        }

        Button {
            id: login

            anchors.top: remeber.bottom
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter

            width:  120;
            height: 30

            flat: true
            enabled: root.statusJoined

            text: qsTr("Войти")

            background: Rectangle {
                radius: 10
                color: "#4f92c9"
            }

            contentItem: Label {
                color: "white"
                font.pointSize: 10
                text: login.text
                verticalAlignment:   Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    if (inputName.text !== "" && inputPassword.text !== "" && inputKeyword.text !== "")
                    {
                        mainWindow.avtorizate(inputName.text,
                                              inputPassword.text,
                                              inputKeyword.text)
                        inputName.text     = ""
                        inputPassword.text = ""
                        inputKeyword.text  = ""
                    }
                }
            }
        }

        Button {
            id: buttonForgot

            anchors.top: keyword.bottom
            anchors.topMargin: 5
            anchors.left: remeber.right
            anchors.leftMargin: 80

            width:  buttonForgot.text.width;
            height: buttonForgot.text.height
            flat: true

            text: qsTr("Forgot Password?")

            background: Rectangle {
                opacity: 0
            }

            contentItem: Label {
                id: labelForgot
                color: "#AAAAAA"
                text: buttonForgot.text
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

        Button {
            id: toReg

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            width:  toReg.text.width;
            height: toReg.text.height
            flat: true

            text: qsTr("Зарегистрироваться")

            background: Rectangle {
                opacity: 0
            }

            contentItem: Label {
                color: "#579ed9"
                font.pointSize: 9
                text: toReg.text
                font.underline: true
                verticalAlignment:   Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    seqAni_avt_close.start()
                }
            }
        }
    }

    Rectangle {
        id: blockReg

        width:  360
        height: 460

        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#313840"
        radius: 15

        border.width: 1
        border.color: "white"

        visible: false

        ScrollView {
            id: flickableReg
            anchors.fill: parent
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Item {
                width: parent.width
                height: 580
                implicitHeight: height

                Button {
                    id: iconUser

                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    enabled: true
                    flat: true

                    icon.width: 100
                    icon.height: 100
                    icon.color: "white"
                    icon.source: "../../icons/add.png"

                    background: Rectangle {
                        opacity: 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {

                        }
                    }
                }

                Label {
                    id: labelReg

                    anchors.top: iconUser.bottom
                    anchors.topMargin: 15
                    anchors.horizontalCenter: parent.horizontalCenter

                    font.pointSize: 15
                    color: "white"

                    text: qsTr("Регистрация")
                }

                Rectangle {
                    id: nameReg

                    anchors.top: labelReg.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   5
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconNameuserReg
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/id-card.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputNameReg

                        anchors.left: iconNameuserReg.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8

                        width: 90

                        focus: true
                        clip: true

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputTextNameReg
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputNameReg.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Ваше имя")
                        }
                    }

                    Rectangle {
                        id: lineNameReg

                        anchors.bottom: nameReg.bottom
                        anchors.left:   nameReg.left
                        anchors.right:  inputNameReg.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }

                    TextInput {
                        id: inputSecondnameReg

                        anchors.left: inputNameReg.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 30

                        width: 125

                        focus: true
                        clip: true

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputTextSecondnameReg
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputSecondnameReg.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Ваша фамилия")
                        }
                    }

                    Rectangle {
                        anchors.bottom: nameReg.bottom
                        anchors.left:   nameReg.left
                        anchors.right:  inputSecondnameReg.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   lineNameReg.width + 25

                        height: 1
                        color: "white"
                    }
                }

                Rectangle {
                    id: email

                    anchors.top: nameReg.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   5
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconEmail
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/email.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputEmail

                        anchors.left: iconEmail.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 8

                        focus: true
                        clip: true

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputEmailName
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputEmail.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Електронная почта")
                        }
                    }

                    Rectangle {
                        anchors.bottom: email.bottom
                        anchors.left:   email.left
                        anchors.right:  email.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }
                }

                Rectangle {
                    id: nick

                    anchors.top: email.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   5
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconNick
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 23
                        icon.height: 23
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/signature.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputNick

                        anchors.left: iconNick.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 8

                        focus: true
                        clip: true

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputNickName
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputNick.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Ваш логин")
                        }
                    }

                    Rectangle {
                        anchors.bottom: nick.bottom
                        anchors.left:   nick.left
                        anchors.right:  nick.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }
                }

                Rectangle {
                    id: number

                    anchors.top: nick.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   5
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconNumber
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 23
                        icon.height: 23
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/contact.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputNumber

                        anchors.left: iconNumber.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 8

                        focus: true
                        clip: true

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputNumberName
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputNumber.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Ваш номер телефона")
                        }
                    }

                    Rectangle {
                        anchors.bottom: number.bottom
                        anchors.left:   number.left
                        anchors.right:  number.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }
                }

                Rectangle {
                    id: passwordReg

                    anchors.top: number.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   10
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconPasswordReg
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/padlock.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputPasswordReg

                        anchors.left: iconPasswordReg.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 8

                        focus: true
                        clip: true
                        echoMode: TextInput.Password

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputTextPasswordReg
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputPasswordReg.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Ваш пароль")
                        }
                    }

                    Button {
                        id: showPasswordReg

                        anchors.verticalCenter: passwordReg.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 5

                        flat: true

                        icon.width:  18
                        icon.height: 18
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/eyeClose.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                if (inputPasswordReg.echoMode === TextInput.Password) {
                                    inputPasswordReg.echoMode = TextInput.Normal
                                    showPasswordReg.icon.source = "../../icons/eyeOpen.png"
                                }
                                else {
                                    showPasswordReg.icon.source = "../../icons/eyeClose.png"
                                    inputPasswordReg.echoMode = TextInput.Password
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: passwordReg.bottom
                        anchors.left:   passwordReg.left
                        anchors.right:  passwordReg.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }
                }

                Rectangle {
                    id: keywordReg
                    anchors.top: passwordReg.bottom
                    anchors.left:  parent.left
                    anchors.right: parent.right

                    anchors.topMargin:   10
                    anchors.leftMargin:  35
                    anchors.rightMargin: 35

                    height: 40

                    color: "transparent"

                    Button {
                        id: iconKeywordReg
                        enabled: false
                        flat: true

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/keyword.png"

                        background: Rectangle {
                            opacity: 0
                        }
                    }

                    TextInput {
                        id: inputKeywordReg

                        anchors.left: iconKeywordReg.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 8

                        focus: true
                        clip: true
                        echoMode: TextInput.Password

                        font.pointSize: 10
                        color: "white"

                        Label {
                            id: inputTextKeywordReg
                            anchors.fill: parent

                            elide: Text.ElideRight
                            opacity: (parent.text !== "") ? 0 : 0.6

                            font.pointSize: inputKeywordReg.font.pointSize
                            color: "#AAAAAA"
                            text: qsTr("Кодовое слово от сервера")
                        }
                    }

                    Button {
                        id: showKeywordReg

                        anchors.verticalCenter: keywordReg.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 5

                        flat: true

                        icon.width:  18
                        icon.height: 18
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/eyeClose.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                if (inputKeywordReg.echoMode === TextInput.Password) {
                                    inputKeywordReg.echoMode   = TextInput.Normal
                                    showKeywordReg.icon.source = "../../icons/eyeOpen.png"
                                }
                                else {
                                    inputKeywordReg.echoMode   = TextInput.Password
                                    showKeywordReg.icon.source = "../../icons/eyeClose.png"
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: keywordReg.bottom
                        anchors.left:   keywordReg.left
                        anchors.right:  keywordReg.right

                        anchors.bottomMargin: 5
                        anchors.leftMargin:   5

                        height: 1
                        color: "white"
                    }
                }

                Button {
                    id: registarte

                    anchors.top: keywordReg.bottom
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    width:  120;
                    height: 30
                    flat: true

                    enabled: root.statusJoined

                    text: qsTr("Зарегистрироваться")

                    background: Rectangle {
                        radius: 10
                        color: "#4f92c9"
                    }

                    contentItem: Label {
                        color: "white"
                        font.pointSize: 9
                        text: registarte.text
                        verticalAlignment:   Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {
                            if (inputNick.text !== "" && inputPasswordReg.text !== "" && inputKeywordReg.text !== "")
                            {
                                mainWindow.registrate(inputNick.text,
                                                      inputPasswordReg.text,
                                                      inputKeywordReg.text)
                                inputNick.text        = ""
                                inputPasswordReg.text = ""
                                inputKeywordReg.text  = ""
                            }
                        }
                    }
                }

                Button {
                    id: backAvt

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: qsTr("Вернуться к авторизации")

                    width:  backAvt.text.width;
                    height: backAvt.text.height
                    flat: true

                    background: Rectangle {
                        opacity: 0
                    }

                    contentItem: Label {
                        color: "#579ed9"
                        text: backAvt.text
                        font.underline: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {
                            seqAni_reg_close.start()
                        }
                    }
                }
            }
        }
    }

    Button {
        id: backWelcome
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
                root.close();
                seqAni_close.start()
            }
        }
    }

    Button {
        id: iconConntect

        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: settings.left
        anchors.rightMargin: 10

        icon.width: 28;
        icon.height: 28
        icon.color:  (root.statusJoined) ? "lime" : ((connectButton.checked) ? "yellow" : "red")
        icon.source: (root.statusJoined) ? "../../icons/connect.png" : "../../icons/disconnect.png"

        flat: true
        enabled: false

        background: Rectangle {
            opacity: 0
        }
    }

    Button {
        id: settings
        flat: true

        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.right: parent.right
        anchors.rightMargin: 15

        icon.width: 20
        icon.height: 20
        icon.color: "#AAAAAA"
        icon.source: "../../icons/settings.png"

        background: Rectangle {
            opacity: 0
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            onClicked: {
                onClicked: settingWindow.open()
            }
        }
    }

    NumberAnimation {
        id: seqAni_open
        target: root
        properties: "visible, scale, opacity"
        to: 1
        duration: 390
    }

    ParallelAnimation {
        id: seqAni_close

        NumberAnimation {
            target: root
            properties: "visible, opacity"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: root
            properties: "scale"
            to: 2
            duration: 390
        }
    }

    ParallelAnimation {
        id: seqAni_avt_close

        NumberAnimation {
            target: blockAvt
            properties: "visible, scale, opacity"
            to: 0
            duration: 390
        }

        NumberAnimation {
            target: blockReg
            properties: "visible, scale, opacity"
            from: 0
            to: 1
            duration: 500
        }
    }

    ParallelAnimation {
        id: seqAni_reg_close

        NumberAnimation {
            target: blockAvt
            properties: "visible, scale, opacity"
            to: 1
            duration: 500
        }

        NumberAnimation {
            target: blockReg
            properties: "visible, scale, opacity"
            to: 0
            duration: 390
        }
    }
}
