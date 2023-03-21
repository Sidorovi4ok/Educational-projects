#pragma once
#include <QObject>
#include "gui/MainWindow.h"
#include "network/Network.h"

class Kernel : public QObject
{
    Q_OBJECT

public:
    explicit Kernel(QObject *parent = nullptr);
    void show();

private:
    MainWindow m_gui;
    Network m_network;

};
