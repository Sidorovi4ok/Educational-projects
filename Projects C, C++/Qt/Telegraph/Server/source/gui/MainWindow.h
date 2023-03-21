#pragma once
#include <QObject>
#include <QQmlApplicationEngine>

class MainWindow : public QObject
{
    Q_OBJECT

public:
    explicit MainWindow(QObject *parent = nullptr);
    ~MainWindow();
    void show();

// Сигналы для связи с network
signals:
    void opened(const quint16 &port, const QString &keyword);
    void closed();

// Сигналы для связи с интерфейсом
signals:
    void consoleMessageQml(const QString &message);
    void openedQml();
    void closedQml();

public slots:
    void onTerminate(const QString &error);
    void consoleMessage(const QString &message);

// Слоты для вызова из интерфейса
public slots:
    Q_INVOKABLE void open(quint16 port, QString keyword);
    Q_INVOKABLE void close();
    Q_INVOKABLE void closeEvent();

private:
    QQmlApplicationEngine m_engine;

};
