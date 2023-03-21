import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

//#ab47bc

Rectangle {
    id: root
    anchors.fill: parent
    color: "#282e33"
    visible: false

    // Сигналы для анимаций
    signal open()
    signal close()
    signal chooseContact()
    signal returnСhoiceContact()

    property bool connectStatus:      false
    property bool loadPublicHistory:  false
    property bool loadPrivateHistory: false

    onLoadPublicHistoryChanged: {
        if (loadPublicHistory) {
            mainWindow.loadHistoryPublic()
        }
    }

    onLoadPrivateHistoryChanged: {
        if (loadPrivateHistory) {
            mainWindow.loadHistoryPrivate(labelTitlePage.text)
        }
    }

    // Коннект c mainWindow
    Connections {
        target: mainWindow

        function onConnected() {
            root.connectStatus = true
        }

        function onDisconnected() {
            root.connectStatus = false
        }

        function onExitAccountFrom() {
            menuUser.close()
            root.close()
            seqAni_close.start()

            publicMessages.clear()
            contacts.clear()
        }

        function onLoadedContact(login, time, online) {
            contacts.append({"online": online, "time": time, "name": login})
        }

        function onUpdateContactsFrom() {
            contacts.clear()
            mainWindow.updateContacts();
        }

        function onLoadedPublicHistory(sender, receiver, time, message, readed) {
            publicMessages.append({"id": "-1", "time": time, "from": sender, "message": message, "readed": readed})
        }

        function onLoadedPrivateHistory(sender, receiver, time, message, readed) {
            privateMessages.append({"id": "-1", "time": time, "from": sender, "message": message, "readed": readed})
        }

        function onMessaged(message) {
            console.log(message);

            let obj = JSON.parse(message);

            if (obj["to"] === "all") {
                publicMessages.insert(0, {"id": "-1", "time": obj["time"], "from": obj["from"], "message": obj["data"], "readed": "0"})
            }
            else {
                if (obj["to"] === labelTitlePage.text || obj["from"] === labelTitlePage.text)
                    privateMessages.insert(0, {"id": "-1", "time": obj["time"], "from": obj["from"], "message": obj["data"], "readed": "0"})
            }
        }

        function onCallFrom(from) {
            abonentCall.text     = from
            labelCall.text       = "Входящий звонок"
            acceptCall.visible   = true
            blockCalling.visible = true;
        }

        function onAsseptFrom() {
            labelCall.text = "00:00"
        }

        function onExitFrom() {
            blockCalling.visible = false
        }

        function onAddFile(filename) {
//            if (swipeChats.currentIndex == 1) {
//                mainWindow.sendFile("all")
//            }
//            else {
//                mainWindow.sendFile(labelTitlePage.text)
//            }

            fileRectangle.visible = true
        }
    }

    // Коннект для анимаций
    Connections {
        target: root

        function onOpen() {
            seqAni_open.start()
        }

        function onChooseContact() {
            aniMenu_close.start()
            aniPrivateChat_open.start()
        }

        function onReturnСhoiceContact() {
            aniPrivateChat_close.start()
            aniMenu_open.start()
        }
    }

    Rectangle {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 55
        color: "#313840"

        Rectangle {
            id: iconUserBlock

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15

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

        Button {
            id: iconConntect

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 15

            icon.width: 28;
            icon.height: 28
            icon.color:  (root.connectStatus) ? "lime" : "#ffeb3b"
            icon.source: (root.connectStatus) ? "../../icons/connect.png" : "../../icons/disconnect.png"

            flat: true
            enabled: false

            background: Rectangle {
                opacity: 0
            }
        }

        Drawer {
            id: menuUser

            modal: true
            interactive: (root.visible) ? true : false

            width: 250
            height: root.height
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

                height: 55
                color: "#313840"

                Rectangle {
                    id: iconMenuUserBlock

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    width: 45; height: width
                    radius: height / 2

                    Button {
                        id: iconMenuUser

                        anchors.fill: parent
                        anchors.margins: 5
                        flat: true
                        enabled: false

                        icon.width: 50
                        icon.height: 50
                        icon.color: "transparent"
                        icon.source: iconUser.icon.source

                        background: Rectangle {
                            opacity: 0
                        }
                    }
                }

                Label {
                    id: menuUserLogin

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: iconMenuUserBlock.right
                    anchors.leftMargin: 15

                    color: "white"
                    font.pointSize: 10
                    font.italic: true

                    text: mainWindow.m_login
                }
            }

            Rectangle {
                id: menuUserBody

                anchors.fill: parent
                anchors.topMargin: menuUserHeader.height + 5

                color: "#282e33"

                Rectangle {
                    id: menuUserBodySetting

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: menuUserBody.top
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

                        text: qsTr("Настройки")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {

                        }
                    }

                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        icon.width: 18;
                        icon.height: 18
                        icon.color:  "white"
                        icon.source: "../../icons/settings.png"

                        flat: true
                        enabled: false

                        background: Rectangle {
                            opacity: 0
                        }
                    }
                }

                Rectangle {
                    id: menuUserBodyHelp

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: menuUserBodySetting.top
                    anchors.topMargin: menuUserBodySetting.height + 8
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

                        text: qsTr("Об Telegraph")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {

                        }
                    }

                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        icon.width: 18;
                        icon.height: 18
                        icon.color:  "white"
                        //icon.source: "../../icons/settings.png"

                        flat: true
                        enabled: false

                        background: Rectangle {
                            opacity: 0
                        }
                    }
                }

                Rectangle {
                    id: menuUserBodyExit

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: menuUserBodyHelp.top
                    anchors.topMargin: menuUserBodyHelp.height + 8
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
                            mainWindow.exitAccount(mainWindow.m_login)
                        }
                    }

                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        icon.width: 18;
                        icon.height: 18
                        icon.color:  "white"
                        icon.source: "../../icons/logout.png"

                        flat: true
                        enabled: false

                        background: Rectangle {
                            opacity: 0
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: body

        anchors.fill: parent
        anchors.topMargin: header.height + 5
        color: "#313840"

        Label {
            id: labelTitlePage

            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter

            font.bold: true
            font.pointSize: 14
            color: "white"

            text: swipeChats.currentItem.title
        }

        Button {
            id: backСhoiceContact

            flat: true
            visible: false

            anchors.top: parent.top
            anchors.topMargin: 5
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
                    mainWindow.clearPrivateId();

                    root.returnСhoiceContact()
                    swipeChats.interactive = true
                    labelTitlePage.text = swipeChats.currentItem.title

                    privateMessages.clear()
                }
            }
        }

        Button {
            id: callContact

            flat: true
            visible: false

            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: menuCurrentContact.left
            anchors.rightMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/telephone-call.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    mainWindow.call(labelTitlePage.text)
                    abonentCall.text     = labelTitlePage.text
                    acceptCall.visible   = false
                    blockCalling.visible = true
                }
            }
        }

        Button {
            id: menuCurrentContact

            flat: true
            visible: false

            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 15

            icon.width: 20
            icon.height: 20
            icon.color: "#AAAAAA"
            icon.source: "../../icons/menu3.png"

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

        SwipeView {
            id: swipeChats

            currentIndex: 1
            anchors.fill: parent
            anchors.topMargin: 35

            Page {
                id: privateChat
                title: qsTr("Личный чат")

                background: Rectangle {
                    color: "transparent"
                }

                Rectangle {
                    id: menuContacts

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: (parent.width > 700) ? parent.width * 0.4 : parent.width
                    color: "#282e33"

                    radius: 10
                    border.width: 3
                    border.color: "#313840"

                    Label {
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        anchors.horizontalCenter: parent.horizontalCenter

                        visible: (contacts.count === 0) ? true : false

                        font.bold: true
                        font.pointSize: 12
                        color: "white"

                        text: qsTr("Список контактов пуст.")
                    }

                    ListModel {
                        id: contacts
                    }

                    ListView {
                        id: contactsView
                        model: contacts
                        spacing: 10

                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        visible: (contacts.count > 0) ? true : false

                        clip: true
                        flickableDirection: Flickable.VerticalFlick

                        delegate: Rectangle {
                            id: contactsDelegate

                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            height: 45
                            radius: 10

                            color: "#353c43"
                            border.width: 1
                            border.color: "#AAAAAA"

                            Label {
                                id: contactTime

                                anchors.left: parent.left
                                anchors.bottom: parent.bottom

                                anchors.leftMargin: 15
                                anchors.bottomMargin: 5

                                font.pointSize: 7

                                color: "#AAAAAA"
                                text: (online === "1") ? "Сейчас в сети" : "Последний раз в сети: " + time
                            }

                            Text {
                                id: contactName

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.left: parent.left
                                anchors.top: parent.top

                                anchors.leftMargin: 15
                                anchors.topMargin: 5

                                font.pointSize: 10
                                font.bold: true

                                color: "white"
                                text: name
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: "PointingHandCursor"

                                onClicked: {

                                    mainWindow.loadHistoryPrivate(name)

                                    labelTitlePage.text = name
                                    swipeChats.interactive = false
                                    root.chooseContact()
                                }
                            }

                            Component.onCompleted: {
                                anchors.left  = parent.left
                                anchors.right = parent.right
                            }
                        }
                    }

                    ParallelAnimation {
                        id: aniMenu_open

                        NumberAnimation {
                            target: menuContacts
                            properties: "visible, opacity, width"
                            to: 1
                            duration: 390
                        }

                        NumberAnimation {
                            target: menuContacts
                            properties: "width"
                            to: (parent.width > 700) ? parent.width * 0.4 : parent.width
                            duration: 390
                        }

                        NumberAnimation {
                            target: labelSelectContact
                            properties: "visible, opacity, width"
                            to: 1
                            duration: 390
                        }

                        NumberAnimation {
                            target: pageIndicator
                            properties: "visible, opacity"
                            to: 1
                            duration: 390
                        }
                    }

                    ParallelAnimation {
                        id: aniMenu_close

                        NumberAnimation {
                            target: menuContacts
                            properties: "visible, opacity, width"
                            to: 0
                            duration: 390
                        }

                        NumberAnimation {
                            target: labelSelectContact
                            properties: "visible, opacity, width"
                            to: 0
                            duration: 390
                        }

                        NumberAnimation {
                            target: pageIndicator
                            properties: "visible, opacity"
                            to: 0
                            duration: 390
                        }
                    }
                }

                Label {
                    id: labelSelectContact

                    anchors.left: menuContacts.right
                    anchors.leftMargin: (parent.width - menuContacts.width) * 0.25
                    anchors.verticalCenter: parent.verticalCenter

                    visible: (parent.width > 700) ? true : false

                    color: "white"
                    font.bold: true
                    font.pointSize: 11

                    z: 1000

                    text: qsTr("Выберите, кому хотели бы написать")

                    background: Rectangle {
                        height: labelSelectContact.height + 5

                        radius: 12
                        opacity: 0.5
                        color: "#18191d"
                    }
                }

                ListModel {
                    id: privateMessages
                }

                ListView {
                    id: viewPrivateMessages
                    model: privateMessages

                    anchors.fill: parent
                    anchors.bottomMargin: privateChatFooter.height + 10
                    anchors.margins: 10

                    visible: false

                    spacing: 8
                    clip: true
                    rotation: 180
                    flickableDirection: Flickable.VerticalFlick

                    delegate: Rectangle {
                        id: privateMessageBlock

                        readonly property int messsageBlockWidth: viewPrivateMessages.width * 0.45

                        width: Math.min(messsageBlockWidth,
                                        (privateTextMessage.implicitWidth +
                                         privateSenderMessage.implicitWidth +
                                         privateTimeMessage.width +
                                         privateMessageRead.width + 10)
                                        )
                        height: privateTextMessage.contentHeight + 40

                        radius: 15
                        rotation: 180
                        color: "#8378DB"

                        Label {
                            id: privateIdMessage
                            visible: false
                            text: id
                        }

                        Text {
                            id: privateSenderMessage

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 10

                            color: "white"
                            font.pointSize: 10
                            font.italic: true

                            text: from
                        }

                        Text {
                            id: privateTextMessage

                            anchors.top: privateSenderMessage.top
                            anchors.left: parent.left
                            anchors.right: parent.right

                            anchors.topMargin: 15
                            anchors.leftMargin: 10

                            color: "white"
                            font.pointSize: 10

                            wrapMode: Text.Wrap

                            text: message
                        }

                        Label {
                            id: privateTimeMessage

                            anchors.right: privateMessageRead.left
                            anchors.top: privateTextMessage.bottom

                            anchors.rightMargin: 5
                            anchors.topMargin: 1

                            font.pointSize: 8
                            color: "#AAAAAA"
                            text: time
                        }

                        Button {
                            id: privateMessageRead

                            enabled: true
                            flat: true

                            anchors.right: parent.right
                            anchors.top: privateTextMessage.bottom

                            anchors.rightMargin: 2
                            anchors.topMargin: -2.5

                            icon.width: 14
                            icon.height: 14
                            icon.color: "#AAAAAA"
                            icon.source: (readed === "1") ? "../../icons/readed.png" : "../../icons/noRead.png"

                            background: Rectangle {
                                opacity: 0
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {

                            }
                        }

                        Component.onCompleted: {
                            if (from === mainWindow.m_login) {
                                anchors.left = parent.left
                                anchors.leftMargin = 10
                                privateSenderMessage.visible = false
                            }
                            else {
                                //publicMessageBlock.color = "red"
                                privateSenderMessage.visible = false
                                anchors.right = parent.right
                                anchors.rightMargin = 10
                            }
                        }
                    }

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ScrollBar.vertical: ScrollBar {
                        id: scrollPrivateChat

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 45
                        anchors.left: parent.left
                        anchors.leftMargin: 2

                        active: true
                        visible: false

                        onVisualSizeChanged: {
                            loadPrivateHistory = (visualPosition > 0) && (visualPosition > scrollPrivateChat.size)
                        }
                    }

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    id: privateChatFooter

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    visible: false
                    height: (privateInputMessage.lineCount <= 4 && privateInputMessage.lineCount === 1) ? 40 :
                            (privateInputMessage.lineCount <= 4 && privateInputMessage.lineCount !== 1) ? (40 + (privateInputMessage.lineCount * 7)) : 80

                    color: "#282e33"

                    Button {
                        id: privateIconFile

                        enabled: true
                        flat: true

                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        anchors.leftMargin: 5
                        anchors.bottomMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/file.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                loadFile.open()
                            }
                        }
                    }

                    ScrollView {
                        id: privateMessageAreaScrollView

                        anchors.left: privateIconFile.right
                        anchors.right: privateSendSmile.left
                        anchors.bottom: parent.bottom

                        anchors.leftMargin: 10
                        anchors.rightMargin: 15

                        opacity: enabled ? 1 : 0.7

                        height: parent.height - 5

                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextArea {
                            id: privateInputMessage

                            color: "white"
                            font.pointSize: 10
                            clip: true

                            opacity: (privateInputMessage.text !== "") ? 1 : 0.6

                            wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere

                            placeholderTextColor: "#AAAAAA"
                            placeholderText: "Написать сообщение..."

                            background: Rectangle {
                                color: "transparent"
                            }

                            Shortcut {
                                context: Qt.ApplicationShortcut
                                sequence: "Ctrl+Return"
                                onActivated: {
                                    if (privateInputMessage.text !== "") {
                                        mainWindow.message(labelTitlePage.text, privateInputMessage.text)
                                        privateInputMessage.text = null
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        id: privateSendSmile

                        anchors.right: privateSendMessage.left
                        anchors.bottom: parent.bottom

                        anchors.rightMargin: 10
                        anchors.bottomMargin: 5

                        flat: true

                        icon.width: 20;
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/smile.png"

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

                    Button {
                        id: privateSendVoiceMessage

                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        anchors.rightMargin: 10
                        anchors.bottomMargin: 5

                        flat: true

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/audio.png"
                        visible: (privateSendMessage.visible) ? false : true

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

                    Button {
                        id: privateSendMessage

                        anchors.bottom: parent.bottom
                        anchors.right: parent.right

                        anchors.bottomMargin: 5
                        anchors.rightMargin: 10

                        flat: true

                        icon.width: 20;
                        icon.height: 20
                        icon.color: "#60a8e7"
                        icon.source: "../../icons/send.png"
                        visible: (privateInputMessage.text !== "") ? true : false

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                if (privateInputMessage.text !== "") {
                                    mainWindow.message(labelTitlePage.text, privateInputMessage.text);
                                    privateInputMessage.text = ""
                                }
                            }
                        }
                    }
                }

                ParallelAnimation {
                    id: aniPrivateChat_open

                    NumberAnimation {
                        target: viewPrivateMessages
                        properties: "visible, scale, opacity"
                        from: 0
                        to: 1
                        duration: 390
                    }

                    NumberAnimation {
                        target: privateChatFooter
                        properties: "visible, scale, opacity"
                        from: 0
                        to: 1
                        duration: 390
                    }

                    NumberAnimation {
                        target: backСhoiceContact
                        properties: "visible, scale, opacity"
                        from: 0
                        to: 1
                        duration: 390
                    }

                    NumberAnimation {
                        target: callContact
                        properties: "visible, scale, opacity"
                        from: 0
                        to: 1
                        duration: 390
                    }

                    NumberAnimation {
                        target: menuCurrentContact
                        properties: "visible, scale, opacity"
                        from: 0
                        to: 1
                        duration: 390
                    }
                }

                ParallelAnimation {
                    id: aniPrivateChat_close

                    NumberAnimation {
                        target: viewPrivateMessages
                        properties: "visible, scale, opacity"
                        from: 1
                        to: 0
                        duration: 390
                    }

                    NumberAnimation {
                        target: privateChatFooter
                        properties: "visible, scale, opacity"
                        from: 1
                        to: 0
                        duration: 390
                    }

                    NumberAnimation {
                        target: backСhoiceContact
                        properties: "visible, scale, opacity"
                        from: 1
                        to: 0
                        duration: 390
                    }

                    NumberAnimation {
                        target: callContact
                        properties: "visible, scale, opacity"
                        from: 1
                        to: 0
                        duration: 390
                    }

                    NumberAnimation {
                        target: menuCurrentContact
                        properties: "visible, scale, opacity"
                        from: 1
                        to: 0
                        duration: 390
                    }
                }
            }

            Page {
                id: publicChat
                title: qsTr("Общий чат")

                background: Rectangle {
                    color: "transparent"
                }

                ListModel {
                    id: publicMessages
                }

                ListView {
                    id: viewPublicMessages
                    model: publicMessages

                    anchors.fill: parent
                    anchors.bottomMargin: (fileRectangle.visible !== true) ? publicChatFooter.height + 10 : fileRectangle.height + publicChatFooter.height + 10
                    anchors.margins: 10

                    spacing: 8
                    clip: true
                    rotation: 180
                    flickableDirection: Flickable.VerticalFlick

                    delegate: Rectangle {
                        id: publicMessageBlock

                        readonly property int messsageBlockWidth: viewPublicMessages.width * 0.45

                        width: Math.min(messsageBlockWidth, (publicTextMessage.implicitWidth + publicSenderMessage.implicitWidth + publicTimeMessage.width + messageIconRead.width + 10))
                        height: publicTextMessage.contentHeight + 40

                        radius: 15
                        rotation: 180
                        color: "#8378DB"

                        Label {
                            id: publicIdMessage
                            visible: false
                            text: id
                        }

                        Text {
                            id: publicSenderMessage

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 10

                            color: "white"
                            font.pointSize: 10
                            font.italic: true

                            text: from
                        }

                        Text {
                            id: publicTextMessage

                            anchors.top: publicSenderMessage.top
                            anchors.left: parent.left
                            anchors.right: parent.right

                            anchors.topMargin: 15
                            anchors.leftMargin: 10

                            color: "white"
                            font.pointSize: 10

                            wrapMode: Text.Wrap

                            text: message
                        }

                        Label {
                            id: publicTimeMessage

                            anchors.right: messageIconRead.left
                            anchors.top: publicTextMessage.bottom

                            anchors.rightMargin: 5
                            anchors.topMargin: 1

                            font.pointSize: 8
                            color: "#AAAAAA"
                            text: time
                        }

                        Button {
                            id: messageIconRead

                            enabled: true
                            flat: true

                            anchors.right: parent.right
                            anchors.top: publicTextMessage.bottom

                            anchors.rightMargin: 2
                            anchors.topMargin: -2.5

                            icon.width: 14
                            icon.height: 14
                            icon.color: "#AAAAAA"
                            icon.source: (readed === "1") ? "../../icons/readed.png" : "../../icons/noRead.png"

                            background: Rectangle {
                                opacity: 0
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {

                            }
                        }

                        Component.onCompleted: {
                            if (from === mainWindow.m_login) {
                                anchors.left = parent.left;
                                anchors.leftMargin = 10;
                                publicSenderMessage.visible = false
                            }
                            else {
                                //publicMessageBlock.color = "red"
                                anchors.right = parent.right;
                                anchors.rightMargin = 10;
                            }
                        }
                    }

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ScrollBar.vertical: ScrollBar {
                        id: scrollPublicChat

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 45
                        anchors.left: parent.left
                        anchors.leftMargin: 2

                        active: true
                        visible: false

                        onVisualSizeChanged: {
                            loadPublicHistory = (visualPosition > 0) && (visualPosition > scrollPublicChat.size)
                        }
                    }

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    id: fileRectangle

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: publicChatFooter.top

                    height: 100

                    color: "#282e33"

                    visible: false

                    Rectangle {
                        id: bottomBorder
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 0.5
                        color: "#0F0F0F"
                    }

                    Rectangle {
                        id: fileDelegate

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        anchors.margins: 10

                        width: 100

                        radius: 3
                        color: "#AAAAAA"

                        Label {
                            id: filePhoto

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5

                            font.pointSize: 12
                            color: "white"
                        }

                        Text {
                            id: fileName

                            anchors.top: filePhoto.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right

                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5

                            font.pointSize: 10
                            color: "white"
                            elide: Text.ElideRight
                        }

                        Label {
                            id: fileFormat

                            anchors.top: fileName.bottom
                            anchors.left: parent.left

                            anchors.topMargin: 2
                            anchors.leftMargin: 5

                            font.pointSize: 8
                            color: "white"
                        }

                        Label {
                            id: fileSize

                            anchors.top: fileName.bottom
                            anchors.right: parent.right

                            anchors.topMargin: 2
                            anchors.rightMargin: 5

                            font.pointSize: 8
                            color: "white"
                        }
                    }
                }

                Rectangle {
                    id: publicChatFooter

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: (publicInputMessage.lineCount <= 4 && publicInputMessage.lineCount === 1) ? 40 :
                            (publicInputMessage.lineCount <= 4 && publicInputMessage.lineCount !== 1) ? (40 + (publicInputMessage.lineCount * 7)) : 80
                    color: "#282e33"

                    Button {
                        id: publicSendFile

                        enabled: true
                        flat: true

                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        anchors.leftMargin: 5
                        anchors.bottomMargin: 5

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/file.png"

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                loadFile.visible = true
                            }
                        }
                    }

                    ScrollView {
                        id: publicMessageAreaScrollView

                        anchors.left: publicSendFile.right
                        anchors.right: publicSendSmile.left
                        anchors.bottom: parent.bottom

                        anchors.leftMargin: 10
                        anchors.rightMargin: 15

                        opacity: enabled ? 1 : 0.7

                        height: parent.height - 5

                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextArea {
                            id: publicInputMessage

                            color: "white"
                            font.pointSize: 10
                            clip: true

                            opacity: (publicInputMessage.text !== "") ? 1 : 0.6

                            wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere

                            placeholderTextColor: "#AAAAAA"
                            placeholderText: "Написать сообщение..."

                            background: Rectangle {
                                color: "transparent"
                            }

                            Shortcut {
                                context: Qt.ApplicationShortcut
                                sequence: "Ctrl+Shift+Return"
                                onActivated: {
                                    if (publicInputMessage.text !== "") {
                                        mainWindow.message("all", publicInputMessage.text)
                                        publicInputMessage.text = null
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        id: publicSendSmile

                        anchors.right: publicSendMessage.left
                        anchors.bottom: parent.bottom

                        anchors.rightMargin: 10
                        anchors.bottomMargin: 5

                        flat: true

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/smile.png"

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

                    Button {
                        id: publicSendVoiceMessage

                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        anchors.rightMargin: 10
                        anchors.bottomMargin: 5

                        flat: true

                        icon.width: 20
                        icon.height: 20
                        icon.color: "#AAAAAA"
                        icon.source: "../../icons/audio.png"
                        visible: (publicSendMessage.visible) ? false : true

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

                    Button {
                        id: publicSendMessage

                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        anchors.rightMargin: 10
                        anchors.bottomMargin: 5

                        flat: true

                        icon.width: 20;
                        icon.height: 20
                        icon.color: "#60a8e7"
                        icon.source: "../../icons/send.png"
                        visible: (publicInputMessage.text !== "") ? true : false

                        background: Rectangle {
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: "PointingHandCursor"

                            onClicked: {
                                if (publicInputMessage.text !== "") {
                                    mainWindow.message("all", publicInputMessage.text);
                                    publicInputMessage.text = ""
                                }
                            }
                        }
                    }
                }
            }

            onCurrentIndexChanged: {
                labelTitlePage.text = swipeChats.currentItem.title
            }
        }

        PageIndicator {
            id: pageIndicator

            count: swipeChats.count
            currentIndex: swipeChats.currentIndex

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            visible: (swipeChats.currentIndex === 1) ? false : true

            delegate: Rectangle {
                implicitHeight: 6
                implicitWidth: 6

                radius: width / 2
                color: "#AAAAAA"

                opacity: index === pageIndicator.currentIndex ? 0.95: pressed ? 0.7 : 0.45

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 200
                    }
                }
            }
        }
    }

    Rectangle {
        id: blockCalling

        anchors.fill: parent
        visible: false
        color: "#313840"

        Label {
            id: abonentCall

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            anchors.topMargin: 150

            font.pointSize: 15
            font.bold: true
            font.italic: true

            color: "white"
        }

        Label {
            id: labelCall

            anchors.top: abonentCall.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            anchors.topMargin: 15

            font.pointSize: 10
            font.bold: true
            font.italic: true

            color: "#AAAAAA"
            text: "Вызов абонента..."
        }

        Button {
            id: acceptCall

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.bottomMargin: 25
            flat: true

            icon.width: 30
            icon.height: 30
            icon.color: "lime"
            icon.source: "../../icons/telephone-call.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    acceptCall.visible = false
                    mainWindow.asseptCall(abonentCall.text)
                }
            }
        }

        Button {
            id: exitCall

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: (acceptCall.visible) ? 50 : parent.width * 0.45
            anchors.bottomMargin: 25
            flat: true

            icon.width: 30
            icon.height: 30
            icon.color: "red"
            icon.source: "../../icons/missed-call.png"

            background: Rectangle {
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: "PointingHandCursor"

                onClicked: {
                    blockCalling.visible = false
                    mainWindow.exitCall(abonentCall.text)
                }
            }
        }
    }

    FileDialog {
        id: loadFile
        visible: false

        title: "Please choose a file"
        currentFolder: "D:/"
        nameFilters: ["All files (*.*)"]

        onAccepted: {
            if (currentFile != "")
                mainWindow.selectFile(currentFile)
        }
    }

    NumberAnimation {
        id: seqAni_open
        target: root
        properties: "visible, scale, opacity"
        to: 1
        duration: 420
    }

    NumberAnimation {
        id: seqAni_close
        target: root
        properties: "visible, scale, opacity"
        to: 0
        duration: 420
    }
}
