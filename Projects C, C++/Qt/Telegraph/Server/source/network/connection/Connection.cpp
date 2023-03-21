#include "Connection.h"
#include "message/Message.h"
#include "../../database/Database.h"
#include <cassert>

Connection::Connection(QWebSocket *socket, QString *keyword, QObject *parent)
    : QObject{parent},
      pSocket{socket},
      m_keyword{keyword}
{
    qDebug() << Q_FUNC_INFO << pSocket << *m_keyword;

    assert(pSocket != nullptr);
    pSocket->setParent(this);

    connect(pSocket, &QWebSocket::disconnected, this, [&]()
    {
        if (!m_login.isEmpty()) {
            DataBase::instance().editTime(m_login, QDateTime::currentDateTime().toString("hh:mm dd.MM.yyyy"));
            DataBase::instance().editOnline(m_login, 0);
        }
        emit finished(this);
    });

    connect(pSocket, &QWebSocket::textMessageReceived, this, [&](const QString &message)
    {
        pCurrent->onReceive(message);
    });

    pCurrent->onEnter();
}

Connection::~Connection()
{
    qDebug() << Q_FUNC_INFO << pSocket;
}

void Connection::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    pSocket->close();
}

void Connection::sendMessage(const QString &message)
{
    pSocket->sendTextMessage(message);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Инструментальные функции

bool Connection::correctKeyword(const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << keyword;

    if (keyword == *m_keyword)
    {
        qDebug() << "KEYWORD FROM USER CORRECT";
        return true;
    }
    else {
        qDebug() << "KEYWORD FROM USER NO CORRECT";
        m_message.wrongKeyword();
        return false;
    }
}

void Connection::exitUser(const QString &login)
{
    qDebug() << Q_FUNC_INFO << login;

    DataBase::instance().editTime(login, QDateTime::currentDateTime().toString("hh:mm dd.MM.yyyy"));
    DataBase::instance().editOnline(login, 0);

    emit newMessagePublic(m_message.updateContacts());

    m_login.clear();
    m_message.exit();

    emit exitAccount(this);
    switchState(m_authorize);
}

QString Connection::login()
{
    return m_login;
}

/////////////////////////////// Реализация "Автомат-состояния" ///////////////////////////////////////////////////////////////////
/// Состояние: авторизация пользователя

void Connection::authorize_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

}

void Connection::authorize_t::onExit()
{
    qDebug() << Q_FUNC_INFO;

    // Добавляю подключение в обсервер
    emit m_context.avtorization(&m_context);
}

void Connection::authorize_t::onTimeout()
{
    qDebug() << Q_FUNC_INFO;

}

void Connection::authorize_t::onReceive(const QString &message)
{
    qDebug() << Q_FUNC_INFO << message;

    auto obj = m_context.m_message.fromString(message);

    if (obj.empty())
        return;

    // Авторизация пользователя
    if (obj["type"].toString() == QStringLiteral("authorization"))
    {
        qDebug() << "AVTORIZATION USER";

        // Если кодовое слово совпало с кодовым словом от сервера
        if ( m_context.correctKeyword(obj["keyword"].toString()))
        {
            qDebug() << "IN TRUE";

            if (DataBase::instance().checkUser(obj["login"].toString(),
                                               obj["password"].toString()))
            {
                m_context.m_message.resAvtorization(obj["type"].toString(),
                                                    obj["login"].toString(),
                                                    obj["password"].toString(),
                                                    obj["keyword"].toString(),
                                                    true);
                DataBase::instance().editOnline(obj["login"].toString(), 1);
                m_context.m_login = obj["login"].toString();
                m_context.switchState(m_context.m_work);
            }
            else {
                m_context.m_message.resAvtorization(obj["type"].toString(),
                                                    obj["login"].toString(),
                                                    obj["password"].toString(),
                                                    obj["keyword"].toString(),
                                                    false);
            }
        }
        return;
    }

    // Регистрация пользователя
    if (obj["type"].toString() == QStringLiteral("registration"))
    {
        qDebug() << "REGISTRATION USER";

        // Если кодовое слово совпало с кодовым словом от сервера
        if ( m_context.correctKeyword(obj["keyword"].toString()))
        {
            qDebug() << "IN TRUE";

            if(DataBase::instance().writeUser(obj["login"].toString(),
                                              obj["password"].toString()))
            {
            m_context.m_message.resAvtorization(obj["type"].toString(),
                                                obj["login"].toString(),
                                                obj["password"].toString(),
                                                obj["keyword"].toString(),
                                                true);
            }
            else {
                m_context.m_message.resAvtorization(obj["type"].toString(),
                                                    obj["login"].toString(),
                                                    obj["password"].toString(),
                                                    obj["keyword"].toString(),
                                                    false);
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Состояние: пользователь зашел в аккаунт

void Connection::work_t::onEnter()
{
    qDebug() << Q_FUNC_INFO;

}

void Connection::work_t::onReceive(const QString &message)
{
    qDebug() << Q_FUNC_INFO /*<< message*/;

    if (message.isEmpty())
        return;

    auto obj = m_context.m_message.fromString(message);

/// Выполняются при входе пользователя в аккаунт
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Если приходит сигнал после авторизации пользователя, чтобы загрузить последние сообщения в чат
    if (obj["type"].toString() == QStringLiteral("historyPublic"))
    {
        qDebug() << "LOAD HISTORY PUBLIC";

        if (obj["id"].toInt() == -1)
            obj["id"] = DataBase::instance().lastMessage();

        for (int i = 15; i > 0 && obj["id"].toInt() > 0; --i, obj["id"] = obj["id"].toInt() - 1)
        {
            auto infoMessage = DataBase::instance().getMessage(obj["id"].toInt());

            if (infoMessage[1] == QStringLiteral("all"))
            {
                m_context.m_message.loadMessage("historyPublic",
                                                obj["id"].toInt(),
                                                infoMessage[0],
                                                infoMessage[1],
                                                infoMessage[2],
                                                infoMessage[3],
                                                infoMessage[4]);
            }
            else
            {
                if (i <= 15)
                    ++i;
            }
        }
    }

    // Сигнал загрузить сообщения в привытный чат
    if (obj["type"].toString() == QStringLiteral("historyPrivate"))
    {
        qDebug() << "LOAD PRIVATE HISTORY";

        if (obj["id"].toInt() == -1)
            obj["id"] = DataBase::instance().lastMessage();

        for (int i = 15; i > 0 && obj["id"].toInt() > 0; --i, obj["id"] = obj["id"].toInt() - 1)
        {
            auto infoMessage = DataBase::instance().getMessage(obj["id"].toInt());

            if ((infoMessage[1] == obj["to"].toString() && infoMessage[0] == m_context.m_login) ||
                (infoMessage[1] == m_context.m_login    && infoMessage[0] == obj["to"].toString()))
            {
                m_context.m_message.loadMessage("historyPrivate",
                                                obj["id"].toInt(),
                                                infoMessage[0],
                                                infoMessage[1],
                                                infoMessage[2],
                                                infoMessage[3],
                                                infoMessage[4]);
            }
            else
            {
                if (i <= 15)
                    ++i;
            }
        }
    }

    // Если приходит сигнал, что пользователь отправил сообщение
    if (obj["type"].toString() == QStringLiteral("contacts"))
    {
        qDebug() << "LOAD USER CONTACTS";

        // Получение количества пользователей в бд
        auto countContacts = DataBase::instance().lastUser();

        // Загрузка абонентов в контакты клинета
        if (countContacts > 0)
        {
            for (; countContacts > 0; --countContacts)
            {
                auto infoContact = DataBase::instance().getUser(countContacts);

                if (infoContact[0] != obj["login"].toString())
                    m_context.m_message.loadContact(infoContact[0],
                                                    infoContact[1],
                                                    infoContact[2]);
            }
        }
    }

/// Выполняются в ходе работы
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Если приходит сигнал, обнвоить контакты
    if (obj["type"].toString() == QStringLiteral("updateContacts"))
    {
        qDebug() << "UPDATE USER CONTACTS";

        emit m_context.newMessagePublic(m_context.m_message.updateContacts());
    }

    // Если приходит сигнал, что пользователь отправил сообщение
    if (obj["type"].toString() == QStringLiteral("message"))
    {
        qDebug() << "USER MESSAGING";

        if(DataBase::instance().writeMessage(obj["from"].toString(),
                                             obj["to"].toString(),
                                             obj["time"].toString(),
                                             obj["data"].toString(),
                                             0))
        {
            if (obj["to"].toString() == QStringLiteral("all")) {

                emit m_context.newMessagePublic(message);
            }
            else {
                emit m_context.newMessagePrivate(obj["to"].toString(), message);
            }
        }
        else {
            qDebug() << "ERROR: failed save message in database";
        }
    }

    // Исходящий звонок контакту
    if (obj["type"].toString() == QStringLiteral("callTo"))
    {
        qDebug() << "CALL TO ABONENT";

        m_context.m_currentAbonent = obj["to"].toString();
        emit m_context.newMessagePrivate(obj["to"].toString(), message);
    }

    // Входящий звонок принял
    if (obj["type"].toString() == QStringLiteral("asseptTo"))
    {
        qDebug() << "ASSEPT CALL FROM USER";

        m_context.m_currentAbonent = obj["to"].toString();
        emit m_context.newMessagePrivate(obj["to"].toString(), message);
    }

    // Вышел из звонка
    if (obj["type"].toString() == QStringLiteral("exitTo"))
    {
        qDebug() << "EXIT CALL FROM USER";

        m_context.m_currentAbonent.clear();
        emit m_context.newMessagePrivate(obj["to"].toString(), message);
    }

    // Пришли сэмплы
    if (obj["type"].toString() == QStringLiteral("voiceTo"))
    {
        qDebug() << "PACKET IS ASSEPTED" << m_context.m_currentAbonent;

        emit m_context.newMessagePrivate(m_context.m_currentAbonent, message);
    }

    // Пришел файл
    if (obj["type"].toString() == QStringLiteral("file"))
    {
        qDebug() << "FILE IS ASSEPTED FROM CLIENT";

        if (obj["to"].toString() == QStringLiteral("all")) {

            emit m_context.newMessagePublic(message);
        }
        else {
            emit m_context.newMessagePrivate(obj["to"].toString(), message);
        }
    }

    // Если приходит сигнал, что пользователь вышел из своего аккаунта
    if (obj["type"].toString() == QStringLiteral("exit"))
    {
        qDebug() << "EXIT IN SERVER";

        m_context.exitUser(obj["login"].toString());
    }
}
