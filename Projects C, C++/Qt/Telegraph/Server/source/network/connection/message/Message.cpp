#include "Message.h"

Message::Message(QWebSocket *socket, QObject *parent)
    : QObject{parent},
      m_webSocket{socket}
{

}

Message::~Message()
{

}

void Message::resAvtorization(const QString &type,
                              const QString &login,
                              const QString &password,
                              const QString &keyword,
                              const bool &res) const
{
    qDebug() << Q_FUNC_INFO << type;

    QJsonObject obj;
    obj["type"]     = type;
    obj["login"]    = login;
    obj["password"] = password;
    obj["keyword"]  = keyword;
    obj["result"]   = res;

    m_webSocket->sendTextMessage(toString(obj));
}

void Message::wrongKeyword() const
{
    qDebug() << Q_FUNC_INFO;

    QJsonObject obj;
    obj["type"]   = "wrongKeyword";
    m_webSocket->sendTextMessage(toString(obj));
}

void Message::loadContact(const QString &login,
                          const QString &time,
                          const QString &online)
{
    qDebug() << Q_FUNC_INFO << login << time << online;

    QJsonObject obj;
    obj["type"]     = "contact";
    obj["login"]    = login;
    obj["time"]     = time;
    obj["online"]   = online;

    m_webSocket->sendTextMessage(toString(obj));
}

void Message::loadMessage(const QString &type,
                          const int &id,
                          const QString &sender,
                          const QString &receiver,
                          const QString &time,
                          const QString &message,
                          const QString &readed)
{
    qDebug() << Q_FUNC_INFO << id << sender << receiver << time << message << readed;

    QJsonObject obj;
    obj["type"]      =  type;
    obj["id"]        =  id;
    obj["sender"]    =  sender;
    obj["receiver"]  =  receiver;
    obj["time"]      =  time;
    obj["message"]   =  message;
    obj["readed"]    =  readed;

    m_webSocket->sendTextMessage(toString(obj));
}

QString Message::updateContacts()
{
    qDebug() << Q_FUNC_INFO;

    QJsonObject obj;
    obj["type"] = "updateContacts";

    return(toString(obj));
}

void Message::exit() const
{
    qDebug() << Q_FUNC_INFO;

    QJsonObject obj;
    obj["type"] = "exit";
    m_webSocket->sendTextMessage(toString(obj));
}

// ИНСТРУМЕНТАЛЬНЫЕ ФУНКЦИИ
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

QString Message::toString(const QJsonObject &object) const
{
    QJsonDocument document{object};
    return document.toJson();
}

QJsonObject Message::fromString(const QString &text) const
{
    return QJsonDocument::fromJson(text.toUtf8()).object();
}
