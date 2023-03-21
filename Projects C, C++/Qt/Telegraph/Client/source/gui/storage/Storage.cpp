#include "Storage.h"
#include <QFile>
#include <QJsonDocument>

Storage::Storage()
{
    qDebug() << Q_FUNC_INFO;
}

Storage &Storage::instance()
{
    qDebug() << Q_FUNC_INFO;

    static Storage t_instance;
    return t_instance;
}

Storage::~Storage()
{
    qDebug() << Q_FUNC_INFO;
}

void Storage::saveSetting(const QString &login,
                          const QString &password,
                          const QString &keyword,
                          const QString &server,
                          const bool    &avt) const
{
    qDebug() << Q_FUNC_INFO << login << password << keyword << server << avt;

    QFile t_file {"../Client/settings/settings.json"};
    if (!t_file.open(QIODevice::WriteOnly))
    {
        qDebug() << t_file.errorString();
        return;
    }

    QVariantMap infoMap;
    infoMap.insert("login",     login);
    infoMap.insert("password",  password);
    infoMap.insert("keyword",   keyword);
    infoMap.insert("server",    server);
    infoMap.insert("avt",       avt);

    t_file.write(QJsonDocument(QJsonObject::fromVariantMap(infoMap)).toJson());
    t_file.close();
}

bool Storage::loadSetting()
{
    qDebug() << Q_FUNC_INFO;

    QFile t_file {"../Client/settings/settings.json"};
    if (!t_file.open(QIODevice::ReadOnly))
    {
        qDebug() << t_file.errorString();
        return false;
    }

    QString data;
    data = t_file.readAll();
    t_file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    m_json = doc.object();

    return m_json["avt"].toBool();
}

QString Storage::login() const
{
    qDebug() << Q_FUNC_INFO;

    return m_json["login"].toString();
}

QString Storage::password() const
{
    qDebug() << Q_FUNC_INFO;

    return m_json["password"].toString();
}

QString Storage::keyword() const
{
    qDebug() << Q_FUNC_INFO;

    return m_json["keyword"].toString();
}

QString Storage::server() const
{
    qDebug() << Q_FUNC_INFO;

    return m_json["server"].toString();
}

bool Storage::avt() const
{
    qDebug() << Q_FUNC_INFO;

    return m_json["avt"].toBool();
}
