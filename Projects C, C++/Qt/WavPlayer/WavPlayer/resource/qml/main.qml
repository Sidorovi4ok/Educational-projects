import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Charts

import "components" as MyComponents


ApplicationWindow {
    id: root
    title: qsTr("Telegraph")

    width: 910; height: 450
    visible: true

    property bool notificationAppend:            false
    property string notificationTitleText:       ""
    property string notificationDescriptionText: ""

    Connections {
        target: mainWindow

        function onNotification(title, description) {
            notificationTitleText = title
            notificationDescriptionText = description
            notificationAppend = true
        }
    }

    FileDialog {
        id: fileDialogLoad

        visible: false

        title: "Please choose a file"
        currentFolder: "."
        nameFilters: ["Wav files (*.wav)"]

        onAccepted: {
            if (currentFile != "")
                inputFile.text = mainWindow.openFile(buttonPlay.checkable, currentFile)
        }
    }

    MyComponents.Notification {
        id: notification

        anchors.horizontalCenter: parent.horizontalCenter
        width: 345; height: 80

        notificationTitle.text: notificationTitleText
        descriptionText.text: notificationDescriptionText
        notificationAnimation.running: notificationAppend
    }

    Rectangle {
        width: 695; height: 135
        color: "#959595"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.topMargin: 5

        border.color: "black"
        border.width: 2
        radius: 5

        Label {
            x: 30; y: 11
            font.pointSize: 9
            color: "white"
            text: "<b> Устройства записи: </b>"
        }

        ComboBox {
            id: deviceInput
            x: 211; y: 11
            width: 381; height: 22
            model: mainWindow.inputDevice()
            font.italic: true

            background: Rectangle {
                color: "white"
                border.width: 2
                radius: 5
            }
        }

        Label {
            x: 30; y: 39
            font.pointSize: 9
            color: "white"
            text: "<b>Устройства воспроизведения:</b>"
        }

        ComboBox {
            id: deviceOutput
            x: 211; y: 39
            width: 381; height: 22
            model: mainWindow.outputDevice()
            font.italic: true

            background: Rectangle {
                color: "white"
                border.width: 2
                radius: 5
            }
        }

        Button {
            id: buttonPlay
            x: 600; y: 10;
            width: 75; height: 51
            text: "Play"
            checkable: false

            background: Rectangle {
                border.width: 2
                radius: 6
            }

            onClicked:
            {
                buttonPlay.checkable = !buttonPlay.checkable;
                mainWindow.testOpen(buttonPlay.checkable,
                                    deviceInput.currentIndex,
                                    deviceOutput.currentIndex)
            }
        }

        Label {
            x: 30; y: 90
            font.pointSize: 9
            color: "white"
            text: "<b>Открыть выбранный файл:</b>"
        }

        Rectangle {
            x: 210; y: 80
            width: 301; height: 41
            color: "white"
            border.color: "black"
            border.width: 2
            radius: 5

            TextEdit {
                id: inputFile
                anchors.fill: parent
                font.pointSize: 9
                font.bold: true
                font.italic: true
                color: "black"
            }
        }

        Button {
            id: buttonOpen
            x: 520; y: 80;
            width: 75; height: 41
            text: "Open file"

            background: Rectangle {
                border.width: 2
                radius: 6
            }

            onClicked:
            {
                fileDialogLoad.open();
            }
        }

        Button {
            id: buttonCansel
            x: 600; y: 80;
            width: 75; height: 41
            text: "Cansel"

            background: Rectangle {
                border.width: 2
                radius: 6
            }

            onClicked: {
                if ( mainWindow.closeFile(buttonPlay.checkable) )
                {
                    inputFile.text = ""
                    progress.value = 0
                    progressTime.text = "0:00 | 0:00"
                }
            }
        }
    }
    // ------------------------------------------------------

    Rectangle {
        x: 705; y: 5
        width: 200; height: 135
        color: "#959595"

        border.color: "black"
        border.width: 2
        radius: 5

        Label {
            x: 10; y: 10
            font.pointSize: 9
            color: "white"
            text: "<b>Громкость звука:</b>"
        }

        Label {
            id: volume
            x: 113; y: 10
            font.pointSize: 9
            font.bold: true
            color: "white"
            text: mainWindow.currentVolume()
        }

        Slider {
            id: sliderVolume
            x: 10; y: 35
            width: 169; height: 22

            //from: 1; to: 1000

            value: mainWindow.currentVolume() * 0.01

            onValueChanged: {
                volume.text = mainWindow.test_setVolumeTarget(sliderVolume.value)
            }
        }

        Label {
            x: 10; y: 65
            font.pointSize: 9
            color: "white"
            text: "<b>Продолжительность:</b>"
        }

        ProgressBar {
            id: progress
            x: 10; y: 85
            width: 169; height: 17
            value: mainWindow.currentProgress
            from: 0; to: 100

            background: Rectangle {
                border.width: 2
                border.color: "black"
                radius: 5

                Label {
                    anchors.centerIn: parent
                    color: "black"
                    text: progress.value + "%"
                    font.bold: true
                }
            }
        }

        Label {
            id: progressTime
            x: 65; y: 105
            font.pointSize: 9
            color: "white"
            font.bold: true
            text: mainWindow.m_time
        }
    }
    // ------------------------------------------------------

    Rectangle {
        x: 5; y: 145
        width: 900; height: 300
        color: "#959595"

        border.color: "black"
        border.width: 2
        radius: 5

        Label {
            x: 30; y: 10
            font.pointSize: 9
            color: "white"
            text: "<b>Визуализация:</b>"
        }

        Rectangle {
            y: 50
            width: 800; height: 200
            anchors.centerIn: parent
            border.color: "white"
            border.width: 2
            radius: 5
            color: "gray"

            Aqualizer2 {
                id: visualSound
                x: 50; y: 50
                width: 800; height: 200

                Component.onCompleted: {
                    mainWindow.setPainter(visualSound)
                }
            }
        }
    }
}


