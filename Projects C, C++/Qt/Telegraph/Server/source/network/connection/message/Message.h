#pragma once
#include <QObject>
#include <QWebSocket>
#include <QJsonObject>
#include <QJsonDocument>
#include <memory>

class Message : public QObject
{
    Q_OBJECT

public:
    explicit Message(QWebSocket *socket = nullptr, QObject *parent = nullptr);
    ~Message();

    // Отправка результата авторизации или регистрации клиенту
    void resAvtorization(const QString &type,
                         const QString &login,
                         const QString &password,
                         const QString &keyword,
                         const bool &res) const;

    // Отправка сообщения, что пароль от сервера не верный
    void wrongKeyword() const;

    // Загрузка контактов
    void loadContact(const QString &login,
                     const QString &time,
                     const QString &online);

    // Отправить сообщение
    void loadMessage(const QString &type,
                     const int &id,
                     const QString &sender,
                     const QString &receiver,
                     const QString &time,
                     const QString &message,
                     const QString &readed);

    QString updateContacts();

    // Отправка сообщения, что клиент вышел из аккаунта
    void exit() const;

// Инструментальные функции
public:
    QString toString(const QJsonObject &object) const;
    QJsonObject fromString(const QString &text) const;

private:
    std::unique_ptr<QWebSocket> m_webSocket;

};
