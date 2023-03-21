#include "Kernel.h"

Kernel::Kernel(QObject *parent)
    : QObject{parent}
{
    // Коннекты из MainWindow в Network
    connect(&m_gui, &MainWindow::opened, &m_network, &Network::open);
    connect(&m_gui, &MainWindow::closed, &m_network, &Network::close);

    // Коннекты из Network в MainWindow
    connect(&m_network, &Network::message, &m_gui, &MainWindow::consoleMessage);
    connect(&m_network, &Network::terminate, &m_gui, &MainWindow::onTerminate);

    // Коннекты для изменений в интерфейсе
    connect(&m_network, &Network::opened, &m_gui, &MainWindow::openedQml);
    connect(&m_network, &Network::closed, &m_gui, &MainWindow::closedQml);
}

void Kernel::show()
{
    m_gui.show();
}
