#pragma once
#include <QObject>
#include <QQmlApplicationEngine>

#include <copus.h>
#include <RingBuffer.h>
#include "PortAudioWraper.h"
#include "wavreader/WavReader.h"

class MainWindow : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString m_login      READ getLogin       WRITE setLogin      NOTIFY loginChange)
    Q_PROPERTY(QString m_server     READ getServer      WRITE setServer     NOTIFY serverChange)
    Q_PROPERTY(bool    m_avtStatus  READ getStatus      WRITE setStatus     NOTIFY statusChange)

public:
    explicit MainWindow(QObject *parent = nullptr);
    ~MainWindow();
    void show();

    std::weak_ptr<RingBuffer> ringBuffer();

// ДЛЯ СВОЙСТВ Q_PROPERTY
public:
    void setLogin(const QString &login);
    void setServer(const QString &server);
    void setStatus(const bool &avt);

public slots:
    QString getPassword() const;
    QString getKeyword()  const;
    QString getLogin()    const;
    QString getServer()   const;
    bool    getStatus()   const;


// СИГНАЛЫ ДЛЯ ОБНОВЛЕНИЯ СВОЙСТВ Q_PROPERTY
signals:
    void loginChange();
    void serverChange();
    void statusChange();








// СИГНАЛЫ ДЛЯ СВЯЗИ С NETWORK
signals:
    // Подключение к серверу
    void connectTo(const QString &address);
    void disconnectTo();

    // Авторизация
    void avtorizateTo(const QString &login,
                      const QString &password,
                      const QString &keyword);
    // Регистрация
    void registrateTo(const QString &login,
                      const QString &password,
                      const QString &keyword);

    // Клиент нажал на выход из аккаунта
    void exitAccountTo(const QString &login);

    // Отправка сообщения в Network
    void messageTo(const QString &from,
                   const QString &to,
                   const QString &message);

    // Загрузка истории сообщений в обчщий чат
    void loadHistoryPublicTo();

    void loadHistoryPrivateTo(const QString &to);

    // Обновление контактов
    void updateContactTo();

    //
    void clearPrivateIdTo();

    //
    void callTo(const QString &to);

    //
    void asseptTo(const QString &to);

    //
    void exitTo(const QString &to);

    void voiceTo();

    void sendFileTo(const QString &to, const QString &filepath);

    void timerStop();


// СЛОТЫ ВЫЗЫВАЕМЫЕ ИЗ NETWORK
public slots:
    // Сохранение пользователя после авторизации
    void saveDataUser(const QString &login,
                      const QString &password,
                      const QString &keyword);

    // Очистка данных пользователя при выходе из аккаунта
    void clearDataUser();









// СИГНАЛЫ ДЛЯ СВЯЗИ С QML
signals:
    // Зашел на сервер или вышел
    void joinedServer();
    void exitServer();

    void connected();
    void disconnected();

    // Авторизация прошла успешно
    void avtSuccess();

    // Регистрация прошла успешно
    void regSuccess();

    // Ошибка авторизации или регистрации
    void avtError(const QString &title,
                  const QString &message);

    // Сигнал, что на сервере ты вышел из аккаунта
    void exitAccountFrom();

    // Пришло сообщение
    void messaged(const QString &message);

    void loadedContact(const QString &login,
                       const QString &time,
                       const QString &online);

    // Загрзука истории общего чата
    void loadedPublicHistory(const QString &sender,
                             const QString &receiver,
                             const QString &time,
                             const QString &message,
                             const QString &readed);

    // Загрзука истории приватного чата
    void loadedPrivateHistory(const QString &sender,
                              const QString &receiver,
                              const QString &time,
                              const QString &message,
                              const QString &readed);

    // Сигнал из Network, чтобы обновить контакты
    void updateContactsFrom();

    //
    void callFrom(const QString &from);

    //
    void asseptFrom();

    //
    void voiceFrom(gsl::span<std::uint8_t> src);

    //
    void addFile(const QString filename);

    //
    void exitFrom();


// СЛОТЫ ДЛЯ ВЫЗОВА ИЗ QML
public slots:
    // Присоединиться к серверу или отключиться
    Q_INVOKABLE void connect(const QString &address);
    Q_INVOKABLE void disconnect();

    // Авторизоваться
    Q_INVOKABLE void avtorizate(const QString &login,
                                const QString &password,
                                const QString &keyword);
    // Зарегистрироваться
    Q_INVOKABLE void registrate(const QString &login,
                                const QString &password,
                                const QString &keyword);

    // Выход пользователя из аккаунта
    Q_INVOKABLE void exitAccount(const QString &login);

    // Отправить сообщение
    Q_INVOKABLE void message(const QString &to,
                             const QString &message);

    // Загрузка истории сообщений общего чата
    Q_INVOKABLE void loadHistoryPublic();

    // Загрузка истории сообщений общего чата
    Q_INVOKABLE void loadHistoryPrivate(const QString &to);

    // Обновление контактов
    Q_INVOKABLE void updateContacts();

    Q_INVOKABLE void clearPrivateId();

    // Вызов контакта
    Q_INVOKABLE void call(const QString &to);

    // Принять входящий звонок
    Q_INVOKABLE void asseptCall(const QString &to);

    // Выйти из звонка или не брать входфщий звонок
    Q_INVOKABLE void exitCall(const QString &to);

    //
    Q_INVOKABLE void selectFile(const QString &filePath);

    //
    Q_INVOKABLE void clearFile();

    //
    Q_INVOKABLE void sendFile(const QString &to);

private:
    void openSoundCard(bool inpDevice, bool voice);
    void closeSoundCard();

    void asseptVoice(gsl::span<std::uint8_t> src);


private:
    QQmlApplicationEngine m_engine;

    opus::decoder m_decoder;

    std::shared_ptr<RingBuffer> m_ringBufferTo;
    RingBuffer m_ringBufferFrom;

    WavReader m_reader;
    std::shared_ptr<PortAudio::Device> pDevice;

    QString m_login;
    QString m_password;
    QString m_keyword;
    QString m_server;
    bool    m_avtStatus {false};

    QString m_currentFile {};


private:
    void callbackWav  (gsl::span<PortAudio::Sample>, gsl::span<PortAudio::Sample>);
    void callbackVoice(gsl::span<PortAudio::Sample>, gsl::span<PortAudio::Sample>);

};
