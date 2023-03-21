#include "Network.h"
#include "message/Message.h"
#include <QFile>
#include <QDir>
#include <windows.h>
#include <lmcons.h>

Network::Network(bool avtStatus,
                 QString address,
                 std::weak_ptr<RingBuffer> buffer,
                 QObject *parent )
    : QObject{parent},
      m_webSocket   {std::make_shared<QWebSocket>()},
      m_ringBuffer  {buffer},
      m_message     {m_webSocket},
      m_address     {address},
      m_avtStatus   {avtStatus}
{
    qDebug() << Q_FUNC_INFO;

    pCurrentState->onEnter();

    assert(m_encoder.init(48000, 2, opus::AudioMode::VoIP)); m_encoder.setBitrate(64000);

    connect(m_webSocket.get(), &QWebSocket::connected, this, [&]()
    {
        pCurrentState->onConnected();
    });

    connect(m_webSocket.get(), &QWebSocket::disconnected, this, [&]()
    {
        pCurrentState->onDisconnected();

    });

    connect(m_webSocket.get(), &QWebSocket::textMessageReceived, this, [&](const QString &message)
    {
        pCurrentState->onReceived(message);
    });

    connect(&m_timer, &QTimer::timeout, this, &Network::voiceSend);
}

Network::~Network()
{
    qDebug() << Q_FUNC_INFO;

    disconnect();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Слоты вызываемые из MainWindow

void Network::connectTo(const QString &address)
{
    qDebug() << Q_FUNC_INFO;

    pCurrentState->connectTo(address);
}

void Network::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    pCurrentState->disconnect();
}

void Network::avtorizate(const QString &login, const QString &password, const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    m_message.authorize(login, password, keyword);
}

void Network::registrate(const QString &login, const QString &password, const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    m_message.registrate(login, password, keyword);
}

void Network::exitAccount(const QString &login)
{
    qDebug() << Q_FUNC_INFO << login;

    m_message.exit(login);
    m_message.clearId();
    m_flagLoad = true;
}

void Network::message(const QString &from, const QString &to, const QString &message)
{
    qDebug() << Q_FUNC_INFO << from << to << message;

    emit messaged(emit m_message.message(from, to, message));
}

void Network::loadPublicHistory()
{
    qDebug() << Q_FUNC_INFO;

    emit m_message.loadHistoryPublic();
}

void Network::loadHistoryPrivate(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    emit m_message.loadHistoryPrivate(to);
}

void Network::updateContactsTo()
{
    qDebug() << Q_FUNC_INFO;

    m_message.loadAbonent(getLogin());
}

void Network::clearPrivateId()
{
    qDebug() << Q_FUNC_INFO;

    m_message.saveIdMessagePrivate(-1);
}

void Network::callTo(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    m_message.callTo(to, getLogin());
}

void Network::asseptTo(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    m_message.asseptTo(to);
}

void Network::exitTo(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    m_message.exitTo(to);
}

void Network::voiceTo()
{
    qDebug() << Q_FUNC_INFO;

    m_timer.start(10);
}

void Network::sendFileTo(const QString &to, const QString &file)
{
    qDebug() << Q_FUNC_INFO << to << file;

    m_message.sendFile(to, emit getLogin(), file);
}

void Network::timerStop()
{
    qDebug() << Q_FUNC_INFO;

    m_timer.stop();
}

void Network::voiceSend()
{
    qDebug() << Q_FUNC_INFO;

    if (m_ringBuffer.lock()->readCount() >= 960)
    {
        std::vector<float> buffer; buffer.resize(960);
        if (m_ringBuffer.lock()->read(buffer))
        {
            // Кодирую семплы
            std::vector<std::uint8_t> encodeBuf; encodeBuf.resize(512);

            auto t_encoded = m_encoder.procces(buffer, encodeBuf);
                qDebug() << "Size samples encoded: " << t_encoded.size();

            m_message.sendVoice(t_encoded);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Реализация "Автомат-состояния" ///////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Состояние: разрыва соединения
void Network::disconnected_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

    if (m_context.m_avtStatus)
        m_context.connectTo(m_context.m_address);
}

void Network::disconnected_t::onExit()
{
    qDebug() << Q_FUNC_INFO;
}

void Network::disconnected_t::connectTo(const QString &address)
{
    qDebug() << Q_FUNC_INFO << address;

    m_context.m_address = address;
    m_context.switchState(m_context.m_connecting);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Состояние: создания соединения

void Network::connecting_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

    m_context.m_webSocket.get()->open(QUrl(m_context.m_address));
}

void Network::connecting_t::onExit()
{
    qDebug() << Q_FUNC_INFO;
}

void Network::connecting_t::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    m_context.switchState(m_context.m_disconnected);
    m_context.m_webSocket->close();
}

void Network::connecting_t::onConnected()
{
    qDebug() << Q_FUNC_INFO;

    m_context.switchState(m_context.m_authorize);
    emit m_context.joinedServer();
}

void Network::connecting_t::onDisconnected()
{
    qDebug() << Q_FUNC_INFO;

    onEnter();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Состояние: авторизации

void Network::authorize_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

    if (m_context.m_avtStatus)
    {
        qDebug() << "AVTORIZATION STATUS IS TRUE";

        m_context.m_message.authorize(emit m_context.getLogin(),
                                      emit m_context.getPassword(),
                                      emit m_context.getkeyword());
    }
}

void Network::authorize_t::onExit()
{
    qDebug() << Q_FUNC_INFO;
}

void Network::authorize_t::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    emit m_context.exitServer();
    m_context.switchState(m_context.m_disconnected);
    m_context.m_webSocket->close();

}

void Network::authorize_t::onDisconnected()
{
    qDebug() << Q_FUNC_INFO;

    m_context.switchState(m_context.m_connecting);
}

void Network::authorize_t::onReceived(const QString &message)
{
    qDebug() << Q_FUNC_INFO << message;

    auto obj = m_context.m_message.fromString(message);

    // Результат авторизации пользователя
    if (obj["type"].toString() == QStringLiteral("authorization"))
    {
        qDebug() << "RESULT AVTORIZATION USER";

        if (obj["result"].toBool())
        {
            qDebug() << "IN TRUE AVTORIZATION";

            emit m_context.avtSuccess(obj["login"].toString(),
                                      obj["password"].toString(),
                                      obj["keyword"].toString());
            m_context.switchState(m_context.m_connected);
        }
        else {
            qDebug() << "IN FALSE AVTORIZATION";

            emit m_context.avtError("Авторизация",
                                    "Ошибка: неверный логин или пароль.");
        }
        return;
    }

    if (obj["type"].toString() == QStringLiteral("registration"))
    {
        qDebug() << "RESULT REGISTRATION USER";

        if (obj["result"].toBool())
        {
            qDebug() << "IN TRUE REGISTRATION";

            emit m_context.regSuccess();
        }
        else {
            qDebug() << "IN FALSE REGISTRATION";

            emit m_context.avtError("Регистрация",
                                    "Ошибка: такой логин уже занят.");
        }
        return;
    }

    if (obj["type"].toString() == QStringLiteral("wrongKeyword"))
    {
        qDebug() << "WRONG KEYWORD FROM SERVER";

        emit m_context.avtError("Ошибка",
                                "Неверный пароль от сервера.");
        return;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Состояние: подключен - соединение установлено

void Network::connected_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

    if (m_context.m_flagLoad) {
        m_context.m_message.loadAbonent(m_context.getLogin());
        m_context.m_message.loadHistoryPublic();
        m_context.m_flagLoad = false;
    }

    m_context.m_message.updateContacts();
    emit m_context.connected();
}

void Network::connected_t::onExit()
{
    qDebug() << Q_FUNC_INFO;

    emit m_context.disconnected();
}

void Network::connected_t::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    m_context.m_message.updateContacts();
    m_context.switchState(m_context.m_disconnected);
    m_context.m_webSocket->close();
}

void Network::connected_t::onDisconnected()
{
    qDebug() << Q_FUNC_INFO;

    m_context.switchState(m_context.m_connecting);
}

void Network::connected_t::onReceived(const QString &message)
{
    qDebug() << Q_FUNC_INFO /*<< message*/;

    if (message.isEmpty())
        return;

    auto obj = m_context.m_message.fromString(message);

/// Выполняются при входе пользователя в аккаунт
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Загрзука истории сообщений общего чата
    if(obj["type"].toString() == QStringLiteral("historyPublic"))
    {
        m_context.m_message.saveIdMessagePublic(obj["id"].toInt());
        emit m_context.loadedPublicHistory(obj["sender"].toString(),
                                           obj["receiver"].toString(),
                                           obj["time"].toString(),
                                           obj["message"].toString(),
                                           obj["readed"].toString());
    }

    // Загрзука истории сообщений общего чата
    if(obj["type"].toString() == QStringLiteral("historyPrivate"))
    {
        m_context.m_message.saveIdMessagePrivate(obj["id"].toInt());
        emit m_context.loadedPrivateHistory(obj["sender"].toString(),
                                           obj["receiver"].toString(),
                                           obj["time"].toString(),
                                           obj["message"].toString(),
                                           obj["readed"].toString());
    }

    // Пришел контакт
    if(obj["type"].toString() == QStringLiteral("contact"))
    {
        emit m_context.loadedContact(obj["login"].toString(),
                                     obj["time"].toString(),
                                     obj["online"].toString());
    }

/// Выполняются в ходе работы
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Сигнал обновить контакты
    if(obj["type"].toString() == QStringLiteral("updateContacts"))
    {
        emit m_context.updateContactsFrom();
    }

    // Пришло сообщение
    if(obj["type"].toString() == QStringLiteral("message"))
    {
        emit m_context.messaged(message);
    }

    // Пришел входящий звонок
    if(obj["type"].toString() == QStringLiteral("callTo"))
    {
        qDebug() << "ABONENT CALLING";

        emit m_context.callFrom(obj["from"].toString());
    }

    // Пришел сигнал, что абонент принял звонок
    if(obj["type"].toString() == QStringLiteral("asseptTo"))
    {
        qDebug() << "ABONENT ASSEPTED CALL";

        emit m_context.asseptFrom();
    }

    // Пришел сигнал, что абонент вышел из звонка
    if(obj["type"].toString() == QStringLiteral("exitTo"))
    {
        qDebug() << "EXIT CALL FROM USER";

        emit m_context.exitFrom();
    }

    // Пришли семплы
    if(obj["type"].toString() == QStringLiteral("voiceTo"))
    {
        qDebug() << "SAMPLES IS ASSEPTED FROM ABONENT";

        QByteArray data = obj["data"].toString().toUtf8();
        data = QByteArray::fromBase64(data);

        std::vector<std::uint8_t> t_src; t_src.resize(data.size());
        std::copy_n((std::uint8_t*)data.data(), data.size(), t_src.begin());
            qDebug() << t_src.size();

        emit m_context.voiceFrom(t_src);
    }

    // Пришел файл
    if(obj["type"].toString() == QStringLiteral("file"))
    {
        qDebug() << "FILE IS ASSEPTED FROM ABONENT";

        if(!QDir("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph").exists())
            QDir("C:/Users/" + QString(getenv("username")) + "/Downloads").mkdir("Telegraph");

        QFile saveFile; saveFile.setFileName("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph/" + obj["filename"].toString());
        if (saveFile.open(QIODevice::WriteOnly))
        {
            saveFile.write(QByteArray::fromBase64(obj["data"].toString().toUtf8()));
            saveFile.close();
        }
    }

    // Пришел сигнал о выход из аккаунта
    if (obj["type"].toString() == QStringLiteral("exit"))
    {
        qDebug() << "EXIT IN CLIENT";

        emit m_context.exitAccountFrom();
        m_context.m_avtStatus = false;

        emit m_context.exitServer();
        disconnect();
    }
}
