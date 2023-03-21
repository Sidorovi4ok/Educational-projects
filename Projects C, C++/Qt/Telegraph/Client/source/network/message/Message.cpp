#include "Message.h"
#include <QFile>

inline QString splitFilename(const QString &filepath)
{
    std::string t_filepath = filepath.toStdString();
    std::size_t found = t_filepath.find_last_of("/\\");
    return QString::fromStdString(t_filepath.substr(found + 1));
}

Message::Message(std::weak_ptr<QWebSocket> socket, QObject *parent)
    : QObject{parent},
      m_webSocket{socket}
{

}

Message::~Message()
{
    qDebug() << Q_FUNC_INFO;
}

void Message::authorize(const QString &login,
                        const QString &password,
                        const QString &keyword) const
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    QJsonObject obj;
    obj["type"]     = "authorization";
    obj["login"]    = login;
    obj["password"] = password;
    obj["keyword"]  = keyword;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::registrate(const QString &login,
                         const QString &password,
                         const QString &keyword) const
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    QJsonObject obj;
    obj["type"]     = "registration";
    obj["login"]    = login;
    obj["password"] = password;
    obj["keyword"]  = keyword;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

QString Message::message(const QString &from,
                         const QString &to,
                         const QString &message) const
{
    qDebug() << Q_FUNC_INFO << to << message;

    QJsonObject obj;
    obj["type"]   =   "message";
    obj["from"]   =   from;
    obj["to"]     =   to;
    obj["time"]   =   QDateTime::currentDateTime().toString("hh:mm - dd.MM");
    obj["data"]   =   message;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));

    return(toString(obj));
}

void Message::loadAbonent(const QString &login) const
{
    qDebug() << Q_FUNC_INFO << login;

    QJsonObject obj;
    obj["type"]  = "contacts";
    obj["login"] = login;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::loadHistoryPublic() const
{
    qDebug() << Q_FUNC_INFO;

    QJsonObject obj;
    obj["type"]  = "historyPublic";
    obj["id"]    = m_idPublic;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::loadHistoryPrivate(const QString &to) const
{
    qDebug() << Q_FUNC_INFO << to;

    QJsonObject obj;
    obj["type"]  = "historyPrivate";
    obj["id"]    = m_idPrivate;
    obj["to"]    = to;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::updateContacts() const
{
    qDebug() << Q_FUNC_INFO;

    QJsonObject obj;
    obj["type"] = "updateContacts";

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::exit(const QString &login) const
{
    qDebug() << Q_FUNC_INFO << login;

    QJsonObject obj;
    obj["type"]     = "exit";
    obj["login"]    = login;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::saveIdMessagePublic(const int &id)
{
    m_idPublic = id;

    if (id == 1)
    {
        m_idPublic = 0;
        return;
    }
}

void Message::saveIdMessagePrivate(const int &id)
{
    if (m_idPrivate == 1 && id == 1)
    {
        m_idPrivate = 0;
        return;
    }
    m_idPrivate = id;
}

int Message::idPublic()
{
    return m_idPublic;
}

int Message::idPrivate()
{
    return m_idPrivate;
}

void Message::clearId()
{
    m_idPublic  = -1;
    m_idPrivate = -1;
}

void Message::callTo(const QString &to, const QString &from) const
{
    qDebug() << Q_FUNC_INFO << to;

    QJsonObject obj;
    obj["type"] = "callTo";
    obj["from"] = from;
    obj["to"]   = to;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::asseptTo(const QString &to) const
{
    qDebug() << Q_FUNC_INFO << to;

    QJsonObject obj;
    obj["type"] = "asseptTo";
    obj["to"]   = to;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::exitTo(const QString &to) const
{
    qDebug() << Q_FUNC_INFO << to;

    QJsonObject obj;
    obj["type"] = "exitTo";
    obj["to"]   = to;

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::sendVoice(const gsl::span<uint8_t> &data) const
{
    qDebug() << Q_FUNC_INFO << data.size();

    QJsonObject obj;
    obj["type"] = "voiceTo";

    QByteArray byteArray;
    for (const std::uint8_t &i : data)
        byteArray.push_back(i);

        qDebug() << "Size samples in t_byteArray: " << byteArray.size();

    byteArray = byteArray.toBase64();
    obj["data"] = byteArray.data();

    if (auto pSocket = m_webSocket.lock(); pSocket)
        pSocket->sendTextMessage(toString(obj));
}

void Message::sendFile(const QString &to, const QString &from, const QString &file) const
{
    qDebug() << Q_FUNC_INFO << to << from << file;

    QFile dataFile; dataFile.setFileName(file);

    qDebug() << dataFile.size();

    if (dataFile.size() > 105000000)
    {
        qDebug() << "FILE IS MORE 100mb";
        return;
    }

    if (dataFile.open(QIODevice::ReadOnly))
    {
        QJsonObject obj;
        obj["type"]       =   "file";
        obj["from"]       =   from;
        obj["to"]         =   to;
        obj["time"]       =   QDateTime::currentDateTime().toString("hh:mm - dd.MM");
        obj["filename"]   =   splitFilename(file);

        QByteArray byteArray; byteArray.clear(); byteArray.resize(dataFile.size());

        byteArray = dataFile.readAll();
        obj["data"] = QString::fromUtf8(byteArray.toBase64());

        dataFile.close();

        if (auto pSocket = m_webSocket.lock(); pSocket)
            pSocket->sendTextMessage(toString(obj));
    }
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
