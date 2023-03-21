#pragma once
#include <QObject>
#include <QtSql/QSqlDatabase>

class DataBase : public QObject
{
    Q_OBJECT

public:
    static DataBase &instance();
    ~DataBase();

    QSqlDatabase connection() const;

    // Функции для работы с пользователями
    bool writeUser(const QString &login,
                   const QString &password) const;

    std::vector<QString> getUser(const int &idUser) const;

    bool checkUser(const QString &login,
                   const QString &password) const;

    int lastUser() const;

    void editTime(const QString &login,
                  const QString &time) const;

    void editOnline(const QString &login,
                    const int     &status) const;

// Функции для работы с сообщениями
    bool writeMessage(const QString &from,
                      const QString &to,
                      const QString &time,
                      const QString &data,
                      const int     &status) const;

    void editStatusMessage(const int &id,
                           const int &status) const;

    int lastMessage() const;

    std::vector<QString> getMessage(const int &idMessage) const;

private:
    DataBase();
    QSqlDatabase m_db;

};


