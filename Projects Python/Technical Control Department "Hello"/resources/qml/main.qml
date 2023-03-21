import QtQuick
import QtQuick.Controls
import "components" // Импортируем все свои компоненты из папки: "components"

// Главное окно приложения
ApplicationWindow {
    // id по объекта по которому к нему можно обращаться
    id: root

    // Видимость окна
    visible: true

    // Определение ширины и высоты окна
    width: 620; height: 640
    minimumWidth: 380; minimumHeight: 480
    maximumWidth: 700; maximumHeight: 650

    // Установка цвета фона окна и заголовка приложения
    color: "#282e33"
    title: qsTr("ОТК Привет")

    // Коннект для получения отправляемых сигналов из бекенда
    // Для получения сигнала нужно написать: "on" + Название сигнала с БОЛЬШОЙ БУКВЫ
    Connections {
        // Берем в таргет отправителя сигналов
        target: database

        // Получен сигнал, показать уведомление
        function onNotification(title, info) {
            notification.open(title, info)
        }

        // Получен сигнал, что пользователь авторизовался
        function onAvtorizated(login, fio, role) {
            avtorization.visible = false
            profile.nameWorker = login
            profile.fioWorker  = fio
            profile.roleWorker = role
            profile.visible    = true
        }
    }

    // Коннект для закрытия компонента личного кабинета и открытия компанента авторизации
    Connections {
        target: profile

        // Получен сигнал, что пользователь вышел из аккаунта
        function onExitAccount() {
            profile.visible = false
            avtorization.visible = true
        }
    }

    // Использование компонента уведомления
    Notification {
        id: notification
    }

    // Использование компонента авторизации
    Avtorization {
        id: avtorization
    }

    // Личный профиль пользователя
    Profile {
        id: profile

    }
}
