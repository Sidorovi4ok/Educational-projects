import QtQuick
import QtQuick.Controls
import "components"

ApplicationWindow {
    id: root

    width:  800
    height: 600
    minimumWidth:  380
    minimumHeight: 480

    visible: true
    title: qsTr("Telegraph")
    color: "#282e33"

    property bool avtStatus: mainWindow.m_avtStatus

    Notification {
        id: notification

        Connections {
            target: avtorization

            function onViewNotification(title, message) {
                notification.open(title, message)
            }
        }
    }

    WelcomePage {
        id: welcomePage
        visible: !avtStatus

        Connections {
            target: avtorization
            function onClose() {
                welcomePage.open()
            }
        }

        Connections {
            target: kernel
            function onClose() {
                welcomePage.open()
            }
        }
    }

    Avtorization {
        id: avtorization

        Connections {
            target: welcomePage
            function onClose() {
                avtorization.open()
            }
        }
    }

    Main {
        id: kernel
        visible: avtStatus

        Connections {
            target: avtorization
            function onLoginUser() {
                kernel.open()
            }
        }
    }
}
