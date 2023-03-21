#pragma once

#include <QThread>

class Network : public QThread
{
    Q_OBJECT

public:
    explicit Network(QObject *parent = nullptr);

// Сигналы для связи с интерфейсом
signals:
    void terminate(const QString &error);
    void message(const QString &message);
    void opened();
    void closed();

// Слоты вызываемые из MainWindow
public slots:
    void open(const quint16 &port, const QString &keyword);
    void close();

private:
    quint16 m_port {0};
    QString m_keyword;

// Функция запуска параллельного потока
protected:
    void run() override;

};

