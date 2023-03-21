#include "Subject.h"

Subject::Subject(QObject *parent)
    : QObject{parent}
{

}

void Subject::attach(std::weak_ptr<Connection> p)
{
    qDebug() << Q_FUNC_INFO;

    if (auto p1 = p.lock(); p1)
    {
        m_observers.append(p);
        connect(p1.get(), &Connection::newMessagePublic,  this, &Subject::onMessagePublic);
        connect(p1.get(), &Connection::newMessagePrivate, this, &Subject::onMessagePrivate);

    }

    qDebug() << m_observers.length();
}

void Subject::detach(std::weak_ptr<Connection> p)
{
    qDebug() << Q_FUNC_INFO;

    m_observers.removeIf([p](std::weak_ptr<Connection> observer) {
        auto p1 = p.lock();
        auto p2 = observer.lock();
        if (p1 && p2)
            return p1.get() == p2.get();
        return false;
    });

    qDebug() << m_observers.length();
}

void Subject::onMessageAll(const QString &message)
{
    qDebug() << Q_FUNC_INFO << message;

    for (auto &pObserver : m_observers)
    {
        if (auto pObj = pObserver.lock(); pObj)
        {
            pObj->sendMessage(message);
        }
    }
    return;
}

void Subject::onMessagePublic(const QString &message)
{
    qDebug() << Q_FUNC_INFO /*<< message*/;

    for (auto pSender = sender(); auto &pObserver : m_observers)
    {
        if (auto pObj = pObserver.lock(); pObj)
        {
            if (pSender != pObj.get())
            {
                pObj->sendMessage(message);
            }
        }
    }
}

void Subject::onMessagePrivate(const QString &to, const QString &message)
{
    qDebug() << Q_FUNC_INFO << to /*<< message*/;

    for (auto pSender = sender(); auto &pObserver : m_observers)
    {
        if (auto pObj = pObserver.lock(); pObj)
        {
            if (pSender != pObj.get() && to == pObj->login())
            {
                pObj->sendMessage(message);
            }
        }
    }
}

int Subject::onCountOnline()
{
    return m_observers.count();
}
