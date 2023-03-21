#pragma once
#include <QObject>
#include <QWebSocket>
#include "message/Message.h"

class Connection : public QObject
{
    Q_OBJECT

public:
    explicit Connection(QWebSocket *socket, QString *keyword, QObject *parent = nullptr);
    ~Connection();


    // Функции для работы с сокетом
    void disconnect();
    void sendMessage(const QString &message);

    // Возвращает логин пользователя
    QString login();

// Сигналы для взаимодействия с Subject
signals:
    void newMessagePublic(const QString &message);
    void newMessagePrivate(const QString &to, const QString &message);


// Сигналы для взаимодействия с Network
signals:
    void finished(Connection*);
    void avtorization(Connection*);
    void exitAccount(Connection*);


// Инструментальные функции
private:
    // Проверка, что кодовое слово от сервера корректно
    bool correctKeyword(const QString &keyword);

    // Выход клиента из аккаунта
    void exitUser(const QString &login);


private:
    QWebSocket  *pSocket;
    QString     *m_keyword;
    Message      m_message{pSocket};

    QString      m_login;
    QString      m_currentAbonent;


// Паттерн - "Автомат состояния"
private:
    // Базовый класс
    struct state_t {
        state_t(){}
        virtual ~state_t(){}
        virtual void onEnter(){}
        virtual void onExit(){}
        virtual void onTimeout(){}
        virtual void onReceive(const QString &){}
    };

    // Авторизация
    struct authorize_t : state_t {
        authorize_t(Connection &context) : m_context{context}{};
        void onEnter() override;
        void onExit() override;
        void onTimeout() override;
        void onReceive(const QString &message) override;

    private:
        Connection &m_context;
    };

    // Клиент в системе
    struct work_t : state_t {
        work_t(Connection &context) : m_context{context}{};
        void onEnter() override;
        void onReceive(const QString &message) override;

    private:
        Connection &m_context;
    };

    // Смена состояния
    void switchState(state_t &state) {
        if (pCurrent != &state) {
            pCurrent->onExit();
            pCurrent = &state;
            pCurrent->onEnter();
        }
    }

private:
    authorize_t m_authorize {*this};
    work_t m_work {*this};
    state_t *pCurrent {&m_authorize};
};

