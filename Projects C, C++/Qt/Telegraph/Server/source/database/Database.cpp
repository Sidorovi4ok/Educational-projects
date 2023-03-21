#include "DataBase.h"
#include <QDebug>
#include <QSqlQuery>
#include <QtSql>

#include <QDir>
#include <windows.h>
#include <lmcons.h>

DataBase::DataBase()
{
    if(m_db.isOpen())
        return;

    m_db = QSqlDatabase::addDatabase("QSQLITE");

    if(!QDir("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph").exists())
        QDir("C:/Users/" + QString(getenv("username")) + "/Downloads").mkdir("Telegraph");

    if(!QDir("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph/Server").exists())
        QDir("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph").mkdir("Server");

    m_db.setDatabaseName("C:/Users/" + QString(getenv("username")) + "/Downloads/Telegraph/Server/database.sqlite");

    if (!m_db.open())
    {
        qDebug() << "Error connect to sql: " << m_db.lastError().text();
        return;
    }

    QSqlQuery query(m_db);

    if (!query.exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, login VARCHAR(20) UNIQUE, password VARCHAR(30), time VARCHAR(30), online INTEGER)"))
    {
        qDebug() << "Error - users: " + query.lastError().text();
    }

    if (!query.exec("CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY, sender VARCHAR(20), receiver VARCHAR(30), time VARCHAR(30), message VARCHAR(200), readed INTEGER)"))
    {
        qDebug() << "Error - messages: " + query.lastError().text();
    }
}

DataBase &DataBase::instance()
{
    static DataBase t_instance;
    return t_instance;
}

QSqlDatabase DataBase::connection() const
{
    return m_db;
}

bool DataBase::writeUser(const QString &login, const QString &password) const
{
    qDebug() << Q_FUNC_INFO << login << password;

    if (!m_db.isOpen())
        return false;

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO users(login, password, time, online) VALUES(:t_login, :t_password, :t_time, 0)");
    query.bindValue(":t_login"   ,  login);
    query.bindValue(":t_password",  password);
    query.bindValue(":t_time"    ,  QDateTime::currentDateTime().toString("hh:mm dd.MM"));

    if(!query.exec())
    {
        qDebug() << "ERROR: " + query.lastError().text();
        return false;
    }
    else
    {
        return true;
    }
}

bool DataBase::checkUser(const QString &login, const QString &password) const
{
    qDebug() << Q_FUNC_INFO << login << password;

    if (!m_db.isOpen())
        return false;

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM users WHERE login LIKE :search");
    query.bindValue(":search", "%" + login + "%");

    if(!query.exec())
    {
        qDebug() << query.lastError().text();
        return false;
    }

    QSqlRecord rec = query.record();
    while(query.next())
    {
        if (query.value(rec.indexOf("login")).toString()    == login &&
            query.value(rec.indexOf("password")).toString() == password)
        {
            return true;
        }
    }
    return false;
}

std::vector<QString> DataBase::getUser(const int &idUser) const
{
    qDebug() << Q_FUNC_INFO << idUser;

    if (!m_db.isOpen())
        return {};

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM users WHERE id LIKE :search");
    query.bindValue(":search", idUser);

    if(!query.exec()) {
        qDebug() << query.lastError().text();
        return {};
    }

    QSqlRecord rec = query.record();
    std::vector<QString> result; result.resize(3);
    while(query.next())
    {
        result.insert(result.begin(),     query.value(rec.indexOf("login")).toString());
        result.insert(result.begin() + 1, query.value(rec.indexOf("time")).toString());
        result.insert(result.begin() + 2, query.value(rec.indexOf("online")).toString());
    }

    return result;
}

void DataBase::editTime(const QString &login, const QString &time) const
{
    qDebug() << Q_FUNC_INFO << login << time;

    if (!m_db.isOpen())
        return;

    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET time=:time WHERE login=:login");
    query.bindValue(":time", time);
    query.bindValue(":login", login);

    if(!query.exec())
        qDebug() << "ERROR: " + query.lastError().text();
}

void DataBase::editOnline(const QString &login, const int &status) const
{
    qDebug() << Q_FUNC_INFO << login << status;

    if (!m_db.isOpen())
        return;

    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET online=:online WHERE login=:login");
    query.bindValue(":online", status);
    query.bindValue(":login", login);

    if(!query.exec())
        qDebug() << "ERROR: " + query.lastError().text();
}


bool DataBase::writeMessage(const QString &from, const QString &to,
                            const QString &time, const QString &data,
                            const int &status) const
{
    qDebug() << Q_FUNC_INFO << from << to << time << data << status;

    if (!m_db.isOpen())
        return false;

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO messages(sender, receiver, time, message, readed) VALUES(:t_sender, :t_receiver, :t_time, :t_message, :t_read)");
    query.bindValue(":t_sender",    from);
    query.bindValue(":t_receiver",  to);
    query.bindValue(":t_time",      time);
    query.bindValue(":t_message",   data);
    query.bindValue(":t_read",      status);

    if(!query.exec()) {
        return false;
    }
    else {
        return true;
    }
}

std::vector<QString> DataBase::getMessage(const int &idMessage) const
{
    if (!m_db.isOpen())
        return {};

    QSqlQuery query(m_db);

    query.prepare("SELECT * FROM messages WHERE id LIKE :search");
    query.bindValue(":search", idMessage);

    if(!query.exec()) {
        qDebug() << query.lastError().text();
        return {};
    }

    QSqlRecord rec = query.record();
    std::vector<QString> result; result.resize(5);
    while(query.next())
    {
        result.insert(result.begin()    , query.value(rec.indexOf("sender")).toString());
        result.insert(result.begin() + 1, query.value(rec.indexOf("receiver")).toString());
        result.insert(result.begin() + 2, query.value(rec.indexOf("time")).toString());
        result.insert(result.begin() + 3, query.value(rec.indexOf("message")).toString());
        result.insert(result.begin() + 4, query.value(rec.indexOf("readed")).toString());
    }
    return result;
}

void DataBase::editStatusMessage(const int &id, const int &status) const
{
    if (!m_db.isOpen())
        return;

    QSqlQuery query(m_db);

    query.prepare("UPDATE messages SET readed=:readed WHERE id=:id");
    query.bindValue(":readed", status);
    query.bindValue(":id", id);

    if(!query.exec())
        qDebug() << "ERROR edit status message: " + query.lastError().text();
}

int DataBase::lastMessage() const
{
    if (!m_db.isOpen())
        return -1;

    QSqlQuery query(m_db);

    if (query.exec("SELECT * FROM messages ORDER BY id DESC LIMIT 1"))
    {
        if (query.next())
            return query.value(0).toInt();
    }

    return 0;
}

int DataBase::lastUser() const
{
    if (!m_db.isOpen())
        return -1;

    QSqlQuery query(m_db);

    if (query.exec("SELECT * FROM users ORDER BY id DESC LIMIT 1"))
    {
        if (query.next())
            return query.value(0).toInt();
    }

    return 0;
}

DataBase::~DataBase()
{
    m_db.close();
}
