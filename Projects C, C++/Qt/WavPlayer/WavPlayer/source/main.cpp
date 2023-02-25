#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "gui/MainWindow.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    MainWindow gui;
    gui.show();

    return app.exec();
}
