#include "MainWindow.h"
#include <QGuiApplication>
#include <QQmlContext>

MainWindow::MainWindow(QObject *parent)
    : QObject{parent}
{
    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
                     qGuiApp, [](QObject *obj, const QUrl &) {
        if (!obj)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    m_engine.rootContext()->setContextProperty("mainWindow", this);
}

MainWindow::~MainWindow()
{
    qDebug() << Q_FUNC_INFO;
}

void MainWindow::show()
{
    const QUrl url("qrc:/qml/main.qml");
    m_engine.load(url);
}

void MainWindow::onTerminate(const QString &error)
{
    qDebug() << Q_FUNC_INFO << error;

    emit consoleMessage(error);
    emit closedQml();
}

void MainWindow::consoleMessage(const QString &message)
{
    qDebug() << Q_FUNC_INFO << message;

    emit consoleMessageQml(message);
}

/// СЛОТЫ ВЫЗЫВАЕМЫЕ ИЗ QMl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void MainWindow::open(quint16 port, QString keyword)
{
    qDebug() << Q_FUNC_INFO << port << keyword;

    consoleMessage("Открытие сервера...");
    emit opened(port, keyword);
}

void MainWindow::close()
{
    qDebug() << Q_FUNC_INFO;

    consoleMessage("Закрытие сервера...");
    emit closed();
}

void MainWindow::closeEvent()
{
    qDebug() << Q_FUNC_INFO;

    emit closed();
}
