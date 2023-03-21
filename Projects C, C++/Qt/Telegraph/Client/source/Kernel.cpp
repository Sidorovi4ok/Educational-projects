#include "Kernel.h"
#include <copus.h>

Kernel::Kernel(QObject *parent)
    : QObject{parent}
{
    // Сигнал из MainWindow о подключении или разрыве соединения с сервером
    connect(&m_mainWindow,      &MainWindow::connectTo,                 &m_network,         &Network::connectTo);
    connect(&m_mainWindow,      &MainWindow::disconnectTo,              &m_network,         &Network::disconnect);

    // Сигнал из Network, что вошел на сервер или вышел из него
    connect(&m_network,         &Network::joinedServer,                 &m_mainWindow,      &MainWindow::joinedServer);
    connect(&m_network,         &Network::exitServer,                   &m_mainWindow,      &MainWindow::exitServer);

    // Сигнал из MainWindow о авторизации или регистрации
    connect(&m_mainWindow,      &MainWindow::avtorizateTo,              &m_network,         &Network::avtorizate);
    connect(&m_mainWindow,      &MainWindow::registrateTo,              &m_network,         &Network::registrate);

    // Сигнал из Network, что клиент успешно авторизовался или зарегистрировался или ошибка входа
    connect(&m_network,         &Network::avtSuccess,                   &m_mainWindow,      &MainWindow::saveDataUser);
    connect(&m_network,         &Network::avtSuccess,                   &m_mainWindow,      &MainWindow::avtSuccess);
    connect(&m_network,         &Network::regSuccess,                   &m_mainWindow,      &MainWindow::regSuccess);
    connect(&m_network,         &Network::avtError,                     &m_mainWindow,      &MainWindow::avtError);

    // Сигнал из MainWindow о выходе пользователя из аккаунта
    connect(&m_mainWindow,      &MainWindow::exitAccountTo,             &m_network,         &Network::exitAccount);
    connect(&m_network,         &Network::exitAccountFrom,              &m_mainWindow,      &MainWindow::exitAccountFrom);
    connect(&m_network,         &Network::exitAccountFrom,              &m_mainWindow,      &MainWindow::clearDataUser);

    // Сигнал из Network о подключении или отключении от сервера
    connect(&m_network,         &Network::connected,                    &m_mainWindow,      &MainWindow::connected);
    connect(&m_network,         &Network::disconnected,                 &m_mainWindow,      &MainWindow::disconnected);

    // Получить статус авторизации клиента и его данные для повторной авторизации
    connect(&m_network,         &Network::avtStatus,                    &m_mainWindow,      &MainWindow::getStatus);
    connect(&m_network,         &Network::getLogin,                     &m_mainWindow,      &MainWindow::getLogin);
    connect(&m_network,         &Network::getPassword,                  &m_mainWindow,      &MainWindow::getPassword);
    connect(&m_network,         &Network::getkeyword,                   &m_mainWindow,      &MainWindow::getKeyword);
    connect(&m_network,         &Network::getServer,                    &m_mainWindow,      &MainWindow::getServer);

    // При отправке сообщения
    connect(&m_mainWindow,      &MainWindow::messageTo,                 &m_network,         &Network::message);
    connect(&m_network,         &Network::messaged,                     &m_mainWindow,      &MainWindow::messaged);

    // Загрузка контактов
    connect(&m_network,         &Network::loadedContact,                &m_mainWindow,      &MainWindow::loadedContact);

    // Загрузка сообщений в публичный чат
    connect(&m_mainWindow,      &MainWindow::loadHistoryPublicTo,       &m_network,         &Network::loadPublicHistory);
    connect(&m_network,         &Network::loadedPublicHistory,          &m_mainWindow,      &MainWindow::loadedPublicHistory);

    // Обновление контактов при выходе одного из них или входе в сеть
    connect(&m_network,         &Network::updateContactsFrom,           &m_mainWindow,      &MainWindow::updateContactsFrom);
    connect(&m_mainWindow,      &MainWindow::updateContactTo,           &m_network,         &Network::updateContactsTo);

    // Загрузка истории приватного чата
    connect(&m_mainWindow,      &MainWindow::loadHistoryPrivateTo,      &m_network,         &Network::loadHistoryPrivate);
    connect(&m_network,         &Network::loadedPrivateHistory,         &m_mainWindow,      &MainWindow::loadedPrivateHistory);

    // Очистка последнего загруженного сообщения при выходе из приватного чата
    connect(&m_mainWindow,      &MainWindow::clearPrivateIdTo,          &m_network,         &Network::clearPrivateId);

    // Отправка сигнала, что пытаешься позовнть и сигнал что пришел входящий звонок
    connect(&m_mainWindow,      &MainWindow::callTo,                    &m_network,         &Network::callTo);
    connect(&m_network,         &Network::callFrom,                     &m_mainWindow,      &MainWindow::callFrom);

    // Отправка сигнала, что абонент принял звонок
    connect(&m_mainWindow,      &MainWindow::asseptTo,                  &m_network,         &Network::asseptTo);
    connect(&m_network,         &Network::asseptFrom,                   &m_mainWindow,      &MainWindow::asseptFrom);

    // Отправка сигнала, что абонент вышел из звонка
    connect(&m_mainWindow,      &MainWindow::exitTo,                    &m_network,         &Network::exitTo);
    connect(&m_network,         &Network::exitFrom,                     &m_mainWindow,      &MainWindow::exitFrom);

    //
    connect(&m_mainWindow,      &MainWindow::voiceTo,                   &m_network,         &Network::voiceTo);
    connect(&m_network,         &Network::voiceFrom,                    &m_mainWindow,      &MainWindow::voiceFrom);

    //
    connect(&m_mainWindow,      &MainWindow::timerStop,                 &m_network,         &Network::timerStop);

    connect(&m_mainWindow,      &MainWindow::sendFileTo,                &m_network,         &Network::sendFileTo);

}

void Kernel::show()
{
    m_mainWindow.show();
}
