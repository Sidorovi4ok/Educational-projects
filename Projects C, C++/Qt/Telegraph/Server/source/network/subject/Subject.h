#pragma once
#include "../Connection/Connection.h"

#include <QObject>
#include <memory>

class Subject : public QObject
{
    Q_OBJECT
public:
    explicit Subject(QObject *parent = nullptr);

    void attach(std::weak_ptr<Connection> p);
    void detach(std::weak_ptr<Connection> p);

private slots:
    // Абсолютно всем отправить
    void onMessageAll(const QString &message);

    // Отправить всем кроме отправителя
    void onMessagePublic(const QString &message);

    // Отправить Только адресату
    void onMessagePrivate(const QString &to, const QString &message);

    // Количество пользователей онлайн
    int onCountOnline();

private:
    QList<std::weak_ptr<Connection>> m_observers;

};
