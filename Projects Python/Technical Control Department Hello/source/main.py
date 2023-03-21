from PyQt6.QtGui       import QGuiApplication
from PyQt6.QtQml       import QQmlApplicationEngine
from database.database import DataBase

if __name__ == "__main__":
    import sys

    # Создание экземпляра приложения
    app = QGuiApplication(sys.argv)

    # Создание екземпляра движка для работы с qml
    engine = QQmlApplicationEngine()

    # Создание екземпляра базы данных и попыткa установить подключение с бд
    db = DataBase()
    db.connection

    # Установление взаимодествия qml с объектом класса, который отвечает за работу с бд
    engine.rootContext().setContextProperty("database", db)

    # Загрузка основного файла с окном приложения
    engine.load("../resources/qml/main.qml")

    # Если произошла ошибка загрузки главного окна, приложение завершится с кодом -1
    if not engine.rootObjects():
        sys.exit(-1)

    # Вызов деструктора движка при закрытие окна приложения
    engine.quit.connect(app.quit)

    # Закрытие приложения
    sys.exit(app.exec())
