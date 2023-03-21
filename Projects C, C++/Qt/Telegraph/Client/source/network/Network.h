#pragma once
#include <QTimer>
#include <QObject>
#include <QWebSocket>

#include <copus.h>
#include <RingBuffer.h>
#include "message/Message.h"

class Network : public QObject
{
    Q_OBJECT

public:
    explicit Network(bool avtStatus, QString address, std::weak_ptr<RingBuffer> buffer, QObject *parent = nullptr);
    ~Network() override;

// Слоты вызываемые из MainWindow
public slots:
    // Создание подключения и разрыв подключения с сервером
    void connectTo(const QString &address);
    void disconnect();

    // Авторизация и решистрация пользователя
    void avtorizate(const QString &login,
                    const QString &password,
                    const QString &keyword);

    void registrate(const QString &login,
                    const QString &password,
                    const QString &keyword);

    void exitAccount(const QString &login);

    void message(const QString &from,
                 const QString &to,
                 const QString &message);

    void loadPublicHistory();

    void loadHistoryPrivate(const QString &to);

    void updateContactsTo();

    void clearPrivateId();

    void callTo(const QString &to);

    void asseptTo(const QString &to);

    void exitTo(const QString &to);

    void voiceTo();

    void sendFileTo(const QString &to, const QString &file);

    void timerStop();



// Сигналы для связи с интерфейсом
signals:
    // Вошел или вышел из сервера
    void joinedServer();
    void exitServer();

    // Соединение с сервером, когда уже вошел в аккаунт
    void connected();
    void disconnected();

    // Авторизация прошла успешно
    void avtSuccess(const QString &login,
                    const QString &password,
                    const QString &keyword);

    // Регистрация прошла успешно
    void regSuccess();

    // Ошибка авторизации или регистрации
    void avtError(const QString &title,
                  const QString &message);

    // Получение данных пользователя из MainWindow
    bool    avtStatus();
    QString getLogin();
    QString getPassword();
    QString getkeyword();
    QString getServer();

    // Получил сообщение
    void messaged(const QString &message);

    // Загрзука контакта
    void loadedContact(const QString &login,
                       const QString &time,
                       const QString &online);

    // Загрзука историю общего чата
    void loadedPublicHistory(const QString &sender,
                             const QString &receiver,
                             const QString &time,
                             const QString &message,
                             const QString &readed);

    // Загрузка истории личного чата
    void loadedPrivateHistory(const QString &sender,
                              const QString &receiver,
                              const QString &time,
                              const QString &message,
                              const QString &readed);

    // Пришел сигнал обновить контакты от сервера
    void updateContactsFrom();

    // Сигнал что пришел звонок
    void callFrom(const QString &from);

    // Сигнал, что абонент принял входящий звонок
    void asseptFrom();

    // Пришли семплы
    void voiceFrom(gsl::span<std::uint8_t> src);

    //  Абонент вышел из звонка
    void exitFrom();

    // Вышел из аккаунта
    void exitAccountFrom();



private:
    void voiceSend();



private:
    std::shared_ptr<QWebSocket> m_webSocket;
    std::weak_ptr<RingBuffer> m_ringBuffer;

    opus::encoder m_encoder;

    QTimer     m_timer;
    Message    m_message;

    QString    m_address;
    bool       m_avtStatus;
    bool       m_flagLoad {true};




// Паттерн "Автомат-состояния"
private:
    // Базовый тип:
    struct state_t
    {
        state_t(){}
        virtual ~state_t(){};
        virtual void onEnter(){}
        virtual void onExit(){}
        virtual void connectTo(const QString &){}
        virtual void disconnect(){}
        virtual void onConnected(){}
        virtual void onDisconnected(){}
        virtual void onReceived(const QString &){}
    };

    // Состояния:
    struct disconnected_t : state_t
    {
        disconnected_t(Network &context) : m_context{context}{}

        void onEnter() override;
        void onExit() override;
        void connectTo(const QString &address) override;

    private:
        Network &m_context;
    };

    struct connecting_t : state_t
    {
        connecting_t(Network &context) : m_context{context}{}

        void onEnter() override;
        void onExit() override;
        void disconnect() override;
        void onConnected() override;
        void onDisconnected() override;

    private:
        Network &m_context;
    };

    struct authorize_t : state_t
    {
        authorize_t(Network &context) : m_context{context}{}

        void onEnter() override;
        void onExit() override;
        void disconnect() override;
        void onDisconnected() override;
        void onReceived(const QString &message) override;
    private:
        Network &m_context;
    };

    struct connected_t : state_t
    {
        connected_t(Network &context) : m_context{context}{}

        void onEnter() override;
        void onExit() override;
        void disconnect() override;
        void onDisconnected() override;
        void onReceived(const QString &message) override;
    private:
        Network &m_context;
    };

    // Смена состояния автомата
    void switchState(state_t &state)
    {
        if (pCurrentState != &state) {
            pCurrentState->onExit();
            pCurrentState = &state;
            pCurrentState->onEnter();
        }
    };

private:
    disconnected_t  m_disconnected   {*this};
    connecting_t    m_connecting     {*this};
    authorize_t     m_authorize      {*this};
    connected_t     m_connected      {*this};
    state_t         *pCurrentState   {&m_disconnected};

};
