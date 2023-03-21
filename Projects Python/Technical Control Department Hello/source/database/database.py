from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
import pymysql as mdb
import datetime

# Класс для работы с базой данных
class DataBase(QObject):
    def __init__(self):
        QObject.__init__(self)

        # Описываются свойства класса
        # Сохранение подключения к базе данных
        self._database = None
        self._idUser   = None

    # Сигналы класса
    # Сигналы для взаимодествия с интерфейсом
    notification = pyqtSignal(str, str)         # Отправка уведомления
    avtorizated  = pyqtSignal(str, str, int)    # Отправка сигнала, что пользователь авторизовался

    loadedWorker  = pyqtSignal(str, str, int)   # Отправка сигнала, что загрузился сотрудник и отрисовать его в интерфейсе
    loadedClients = pyqtSignal(str, str, str)   # Отправка сигнала, что загрузился клиент и отрисовать его в интерфейсе
    loadedService = pyqtSignal(str, int)        # Отправка сигнала, что загрузилсась услуга и отрисовать ее в интерфейсе
    loadedOrder   = pyqtSignal(str, str,        # Отправка сигнала, что загрузился заказ и отрисовать его в интерфейсе
                               int, str,
                               int, str, str)
    clearOrders   = pyqtSignal()

    # Методы класса
    # Функция подключения к базе данных
    @property
    def connection(self):
        try:
            self._database = mdb.connect(host        = 'localhost',
                                         user        = 'root',
                                         password    = '1234',
                                         database    = 'examen',
                                         cursorclass = mdb.cursors.DictCursor)
            print("Connection is successfully!")

        except mdb.Error as e:
            print("Connection is error: " + e)







# ------------------------------ ДЛЯ ВХОДА В АККАУНТ -------------------------------------------------------------

    # Авторизация пользователя
    @pyqtSlot(str, str)
    def avt(self, login, password):
        print("Avtorization user..." + login + " " + password)

        try:
            cursor = self._database.cursor()

            if not cursor.execute("SELECT * FROM workers WHERE login = %s", (login,)):
                self.notification.emit("Avtorization",
                                       "Error: login or password is wrong")
                return

            result = cursor.fetchone()

            if result["login"] == login and result["password"] == password:
                self._idUser = result["id"]
                self.avtorizated.emit(result['login'],
                                      result["fio"],
                                      result["role"])
            else:
                self.notification.emit("Avtorization",
                                       "Error: login or password is wrong")

            cursor.close()

        except self._database.Error as e:
            print(e)





#-------------------------------- РАБОТА С СОТРУДИНКАМИ ОТК -------------------------------------------------------

    # Загрузка сотрудников ОТК
    @pyqtSlot()
    def loadWorkers(self):
        print("Load workers...")

        try:
            cursor = self._database.cursor()

            cursor.execute("select * from workers")
            result = cursor.fetchall()

            for data in result:
                self.loadedWorker.emit(data["login"], data["fio"], data["role"])

            cursor.close()

        except self._database.Error as e:
            print(e)



    # Добавление нового сотрудника в бд
    @pyqtSlot(str, str, str, str)
    def appendWorker(self, login, fio, password, role):
        print("Append worker..." + login + " " + fio + " " + password)

        try:
            cursor = self._database.cursor()

            if not cursor.execute("select * FROM roles WHERE name = %s", (role,)):
                self.notification.emit("Регистрация сотрудника",
                                       "Введенная роль не найдена")
                return

            result = cursor.fetchone()
            t_idRole = result["id"]

            if (t_idRole == 2):
                self.notification.emit("Регистрация сотрудника",
                                       "Нельзя зарегистрировать еще одного директора ОТК")
                return

            if cursor.execute("insert into workers (login, fio, password, role) values (%s, %s, %s, %s)",
                             (login, fio, password, t_idRole,)):
                self.notification.emit("Регистрация сотрудника",
                                       "Регистрация прошла успешно")

            self._database.commit()

        except self._database.Error as e:
            self.notification.emit("Ошибка регистрации сотрудника", "Такой логин уже занят")
            print(e)










# ------------------------------ РАБОТА С КЛИЕНТАМИ ---------------------------------------------------------------

    # Загрузка сервисов
    @pyqtSlot()
    def loadClients(self):
        print("Load clients...")

        try:
            cursor = self._database.cursor()

            cursor.execute("select * from clients")
            result = cursor.fetchall()

            for data in result:
                self.loadedClients.emit(data["fio"], data["phone"], data["email"])

            cursor.close()

        except self._database.Error as e:
            print(e)




    # Добавление нового клиента в систему
    @pyqtSlot(str, str, str)
    def appendClient(self, fio, phone, email):
        print("Append client..." + fio + " " + phone + " " + email)

        try:
            cursor = self._database.cursor()
            if cursor.execute("insert into clients (fio, phone, email) values (%s, %s, %s)",
                             (fio, phone, email,)):
                self.notification.emit("Добавление клиента",
                                       "Вы успешно добавили нового клиента")
            else:
                self.notification.emit("Ошибка добавление клиента",
                                       "Такой клиент уже существует")

            self._database.commit()

        except self._database.Error as e:
            self.notification.emit("Ошибка добавление клиента",
                                   "Такой клиент уже существует")
            print(e)





#------------------------------ РАБОТА С СЕРВИСАМИ -----------------------------------------------------------------

    # Загрузка сервисов
    @pyqtSlot()
    def loadServices(self):
        print("Load services...")

        try:
            cursor = self._database.cursor()

            cursor.execute("select * from services")
            result = cursor.fetchall()

            for data in result:
                self.loadedService.emit(data["name"], data["price"])

            cursor.close()

        except self._database.Error as e:
            print(e)




    # Добавление новой услуги в базу
    @pyqtSlot(str, int)
    def appendService(self, name, price):
        print("Append service..." + name)

        try:
            cursor = self._database.cursor()

            if cursor.execute("insert into services (name, price) values (%s, %s)", (name, price, )):
                self.notification.emit("Добавление услуги",
                                       "Вы успешно добавили новую услугу")

            self._database.commit()

        except self._database.Error as e:
            self.notification.emit("Ошибка добавление услуги",
                                   "Такая услуга уже существует или неверные введенные данные")
            print(e)

# ------------------------------ РАБОТА С ЗАКАЗАМИ ------------------------------------------------------------------

    # Загрузка заказов
    @pyqtSlot()
    def loadOrders(self):
        print("Load orders...")

        try:
            cursor = self._database.cursor()

            cursor.execute("select * from orders")
            result = cursor.fetchall()

            for data in result:

                # Получение названия услуги
                cursor.execute("select * FROM services WHERE id = %s", (data["service"],))
                t_resultService = cursor.fetchone()
                t_nameService   = t_resultService["name"]

                # Получение имени клиента
                cursor.execute("select * FROM clients WHERE id = %s", (data["client"],))
                t_resultClient = cursor.fetchone()
                t_nameClient  = t_resultClient["fio"]


                # Получение имени работника
                cursor.execute("select * FROM workers WHERE id = %s", (data["worker"],))
                t_resultWorker = cursor.fetchone()
                t_nametWorker   = t_resultWorker["fio"]

                self.loadedOrder.emit(data["time"],  t_nameService,
                                      data["price"], t_nameClient,
                                      data["sosud"], t_nametWorker,
                                      data["status"])

            cursor.close()

        except self._database.Error as e:
            print(e)


    # Добавление нового заказа в систему
    @pyqtSlot(int, str, str)
    def appendOrder(self, sosud, service, client):
        print("Append order..." + service + " " + client)

        try:
            cursor = self._database.cursor()

            if not cursor.execute("select * FROM services WHERE name = %s", (service,)):
                self.notification.emit("Ошибка добавление заказа",
                                       "Указанная услуга не найдена")
                return
            result = cursor.fetchone()


            t_idService    = result["id"]
            t_priceService = result["price"]


            if not cursor.execute("select * FROM clients WHERE fio = %s", (client,)):
                self.notification.emit("Ошибка добавление заказа",
                                       "Указанная клиент не найден")
                return
            result = cursor.fetchone()


            t_idClint = result["id"]
            t_time = datetime.datetime.now()



            if not cursor.execute("insert into sosuds (id, name, discription) values (%s, %s, %s)",
                                 (sosud, "Название сосуда {sosud}", "Название сосуда {discription}",)):
                self.notification.emit("Ошибка добавление заказа",
                                       "Указанный сосуд уже есть в системе")
                return


            if cursor.execute("insert into orders (time, service, price, client, sosud, worker, status) values (%s, %s, %s, %s, %s, %s, %s)",
                             (t_time.strftime("%d-%m-%Y %H:%M"), t_idService, t_priceService, t_idClint, sosud, self._idUser, "В процессе проверки", )):
                self.notification.emit("Добавление заказа",
                                       "Вы успешно добавили новый заказ")
            else:
                self.notification.emit("Ошибка добавление заказа",
                                       "Такой сосуд уже существует или проверьте вводимые данные")


            self._database.commit()

        except self._database.Error as e:
            self.notification.emit("Ошибка добавление заказа", "Проверьте правильность вводимых данных")
            print(e)

    # Сосуд прошел испытания
    @pyqtSlot(int)
    def confirmOrder(self, sosud):
        print("Confirm order..."); print(sosud)

        try:
            cursor = self._database.cursor()
            cursor.execute("UPDATE orders SET status = %s WHERE sosud = %s", ("Успешно", sosud, ))

            self._database.commit()
            self.clearOrders.emit()
            self.loadOrders()

        except self._database.Error as e:
            print(e)




    # Сосуд НЕ прошел испытания
    @pyqtSlot(int)
    def cancelOrder(self, sosud):
        print("Confirm order..."); print(sosud)

        try:
            cursor = self._database.cursor()
            cursor.execute("UPDATE orders SET status = %s WHERE sosud = %s", ("Провал", sosud, ))

            self._database.commit()
            self.clearOrders.emit()
            self.loadOrders()

        except self._database.Error as e:
            print(e)


