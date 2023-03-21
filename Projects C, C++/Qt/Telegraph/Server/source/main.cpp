#include <QGuiApplication>
#include "Kernel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    Kernel kernel;
    kernel.show();

    return app.exec();
}
