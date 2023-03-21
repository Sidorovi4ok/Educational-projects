TEMPLATE = app      # Тип исполняемого файла
TARGET   = Server   # Название

# Подключение модулей QT6
QT += core quick network websockets sql

# Указываение стандарта c++
CONFIG += c++2a

# Дирректория куда помещается exe файл
DESTDIR = ../bin

# Установка иконки приложения
win32:RC_FILE = resources.rc

SOURCES += source/main.cpp

HEADERS += source/Kernel.h
SOURCES += source/Kernel.cpp

HEADERS += source/gui/MainWindow.h
SOURCES += source/gui/MainWindow.cpp

HEADERS += source/network/Network.h
SOURCES += source/network/Network.cpp

HEADERS += source/database/Database.h
SOURCES += source/database/Database.cpp

HEADERS += source/network/subject/Subject.h
SOURCES += source/network/subject/Subject.cpp

HEADERS += source/network/connection/Connection.h
SOURCES += source/network/connection/Connection.cpp

HEADERS += source/network/connection/message/Message.h
SOURCES += source/network/connection/message/Message.cpp

RESOURCES += resources/resources.qrc
