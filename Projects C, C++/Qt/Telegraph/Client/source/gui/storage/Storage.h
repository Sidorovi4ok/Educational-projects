#pragma once
#include <QObject>
#include <QJsonObject>

class Storage : public QObject
{
    Q_OBJECT

public:
    static Storage &instance();
    ~Storage();

public:
    void saveSetting(const QString &login,
                     const QString &password,
                     const QString &keyword,
                     const QString &server,
                     const bool    &avt) const;
    bool loadSetting();

    QString login()    const;
    QString password() const;
    QString keyword()  const;
    QString server()   const;
    bool avt()         const;

public:
    Storage();
    QJsonObject m_json;

};
