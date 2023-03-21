#pragma once
#include <QObject>
#include <QWebSocket>
#include <QJsonObject>
#include <QJsonDocument>
#include <memory>
#include <span>

class Message : public QObject
{
    Q_OBJECT

public:
    explicit Message(std::weak_ptr<QWebSocket> socket, QObject *parent = nullptr);
    ~Message();

public:

    // Отправка сообщения с авторизацией пользователя
    void authorize(const QString &login,
                   const QString &password,
                   const QString &keyword) const;

    // Отправка сообщения с регистрацией пользователя
    void registrate(const QString &login,
                    const QString &password,
                    const QString &keyword) const;

    // Отправка сообщения
    QString message(const QString &from,
                    const QString &to,
                    const QString &message) const;

    // Отправка сообщения об загрузке контактов сервера
    void loadAbonent(const QString &login) const;

    // Загрузка истории сообщений общего чата
    void loadHistoryPublic() const;

    void loadHistoryPrivate(const QString &to) const;

    // Отпраивть сообщение, чтобы контакты у других пользователей
    void updateContacts() const;

    // Сохранение id сообщений, чтобы знать с какого места продолжать загрузку
    void saveIdMessagePublic(const int &id);
    void saveIdMessagePrivate(const int &id);

    int idPublic();
    int idPrivate();
    void clearId();

    // Звонок
    void callTo(const QString &to, const QString &from) const;

    //
    void asseptTo(const QString &to) const;

    //
    void exitTo(const QString &to) const;

    // Отправить семплы во время звонка
    void sendVoice(const gsl::span<std::uint8_t> &data) const;

    void sendFile(const QString &to, const QString &from, const QString &file) const;

    // Отправка сообщения об выходе пользователя из аккаунта
    void exit(const QString &login) const;

// Инструментальные функции
public:
    QString toString(const QJsonObject &object) const;
    QJsonObject fromString(const QString &text) const;

private:
    std::weak_ptr<QWebSocket> m_webSocket;
    int m_idPublic  {-1};
    int m_idPrivate {-1};

};
