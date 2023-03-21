#include "Network.h"
#include "Connection/Connection.h"
#include "Subject/Subject.h"

#include <memory>
#include <QtWebSockets>

Network::Network(QObject *parent)
    : QThread{parent}
{

}

void Network::open(const quint16 &port, const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << port << keyword;

    if (isRunning())
        return;

    m_port    = port;
    m_keyword = keyword;

    start(); // Запуск параллельного потока
}

void Network::close()
{
    qDebug() << Q_FUNC_INFO;

    if (isRunning())
    {
        quit(); // Закрытие параллельного потока
        wait(); // Ожидание завершения потока
    }
}

void Network::run()
{
    qDebug() << Q_FUNC_INFO;

    QList<std::shared_ptr<Connection>> m_connections; // Линейный список умных указателей на соединения
    QWebSocketServer m_server {"ChatServer", QWebSocketServer::SslMode::NonSecureMode};
    Subject m_subject;

    connect(&m_server, &QWebSocketServer::newConnection, &m_server, [&]()
    {
        // Создаем Экземпляр Connection и передаем ему созданный QWebSocket
        m_connections.emplaceBack(std::make_unique<Connection>(m_server.nextPendingConnection(), &m_keyword));
        emit message("Создание подключения с новым клиентом.");

        connect(m_connections.back().get(), &Connection::avtorization, &m_server, [&](auto pConnect)
        {
            qDebug() << "APPEND CONNECTION IN OBSERVER";

            auto itter = std::find_if(m_connections.begin(), m_connections.end(), [pConnect](auto &conn) { return conn.get() == pConnect; });
            if (itter != m_connections.end())
            {
                m_subject.attach(*itter);
            }
        }, Qt::QueuedConnection);

        connect(m_connections.back().get(), &Connection::exitAccount, &m_server, [&](auto pConnect)
        {
            qDebug() << "DELETE CONNECTION IN OBSERVER";

            auto itter = std::find_if(m_connections.begin(), m_connections.end(), [pConnect](auto &conn) { return conn.get() == pConnect; });
            if (itter != m_connections.end()) {
                m_subject.detach(*itter);
            }
        }, Qt::QueuedConnection);

        //Удаляем объект по событию finished - разрыву соеднения
        connect(m_connections.back().get(), &Connection::finished, &m_server, [&](auto pConnect)
        {
            // Ищем нужный объект
            auto itter = std::find_if(m_connections.begin(), m_connections.end(), [pConnect](auto &conn) { return conn.get() == pConnect; });
            if (itter != m_connections.end()) {
                // Если объект найдет удаляем его
                m_subject.detach(*itter);
                m_connections.erase(itter);
                emit message("Разрыв подключения с клиентом.");
            }
        }, Qt::QueuedConnection);
    });



    if (!m_server.listen(QHostAddress::Any, m_port))
    {
        emit terminate(m_server.errorString());
        return;
    }
    emit message("Сервер открыт.");
    emit opened();

    // Входим в цикл обаботки сообщений
    exec();


    for (auto &pConnect : m_connections) {  // Разорвать все соединения при закрытие сервера
        pConnect->disconnect();
    }
    m_server.close();

    emit message("Сервер закрыт.");
    emit closed();
}
