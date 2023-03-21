#include "MainWindow.h"
#include <QGuiApplication>
#include <QQmlContext>
#include "storage/Storage.h"

inline QString handleFileChosen(const QString &urlString)
{
    const QUrl url(urlString);
    if (url.isLocalFile()) {
        return(QDir::toNativeSeparators(url.toLocalFile()));
    } else {
        return(urlString);
    }
}

inline QString splitFilename(const QString &filepath)
{
    std::string t_filepath = filepath.toStdString();
    std::size_t found = t_filepath.find_last_of("/\\");
    return QString::fromStdString(t_filepath.substr(found + 1));
}

MainWindow::MainWindow(QObject *parent)
    : QObject{parent},
      m_ringBufferTo {std::make_shared<RingBuffer>()}
{
    qDebug() << Q_FUNC_INFO;

    pDevice = PortAudio::instance().create();

    assert(m_decoder.init(48000, 2));
    m_ringBufferTo->resize(1920); m_ringBufferFrom.resize(1920);

    if(setStatus(Storage::instance().loadSetting()), getStatus())
    {
        setLogin(Storage::instance().login());
        m_server   = Storage::instance().server();
        m_password = Storage::instance().password();
        m_keyword  = Storage::instance().keyword();
    }

    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
                     qGuiApp, [](QObject *obj, const QUrl &) {
        if (!obj)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    QObject::connect(this, &MainWindow::callFrom, this, [&]() {

        qDebug() << Q_FUNC_INFO;

        m_reader.open(":/sounds/vibertone.wav");
        openSoundCard(false, false);
    });

    QObject::connect(this, &MainWindow::asseptFrom, this, [&]() {

        qDebug() << Q_FUNC_INFO;

        closeSoundCard();
        openSoundCard(true, true);

        emit voiceTo();
    });

    QObject::connect(this, &MainWindow::exitFrom, this, [&]() {

        qDebug() << Q_FUNC_INFO;

        closeSoundCard();
        m_reader.open(":/sounds/no_answer.wav");
        openSoundCard(false, false);

        emit timerStop();
    });

    QObject::connect(this, &MainWindow::voiceFrom, this, &MainWindow::asseptVoice);

    m_engine.rootContext()->setContextProperty("mainWindow", this);
}

MainWindow::~MainWindow()
{
    qDebug() << Q_FUNC_INFO;

    closeSoundCard();
    Storage::instance().saveSetting(m_login, m_password, m_keyword, m_server , m_avtStatus);
}

void MainWindow::show()
{
    const QUrl url("qrc:/qml/main.qml");
    m_engine.load(url);
}

std::weak_ptr<RingBuffer> MainWindow::ringBuffer()
{
    return m_ringBufferTo;
}

void MainWindow::openSoundCard(bool inpDevice, bool voice)
{
    if (!pDevice->open((inpDevice) ? PortAudio::instance().defaultInputDevice() : nullptr,
                       PortAudio::instance().defaultOutputDevice(),
                       48000,
                       480,
                       std::bind( (voice) ? &MainWindow::callbackVoice : &MainWindow::callbackWav,
                                 this,
                                 std::placeholders::_1,
                                 std::placeholders::_2)))
    {
        qDebug() << "Error: device not opened.";
        pDevice->close();
    }
}

void MainWindow::closeSoundCard()
{
    pDevice->close();
    m_reader.close();
}

void MainWindow::asseptVoice(gsl::span<uint8_t> src)
{
    qDebug() << Q_FUNC_INFO << src.size();

    std::vector<float> t_buffer; t_buffer.resize(960);
    auto t_decoded = m_decoder.procces(src, t_buffer);
        qDebug() << "Size decoded semples: " << t_decoded.size();

    m_ringBufferFrom.write(t_decoded);
}

////// ДЛЯ РАБОТЫ СВОЙСТ Q_PROPERTY В QML
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

QString MainWindow::getLogin() const
{
    return m_login;
}

QString MainWindow::getPassword() const
{
    return m_password;
}

QString MainWindow::getKeyword() const
{
    return m_keyword;
}

void MainWindow::setLogin(const QString &str)
{
    m_login = str;
    emit loginChange();
}

QString MainWindow::getServer() const
{
    return m_server;
}

void MainWindow::setServer(const QString &server)
{
    m_server = server;
    emit serverChange();
}

bool MainWindow::getStatus() const
{
    qDebug() << Q_FUNC_INFO;

    return m_avtStatus;
}

void MainWindow::setStatus(const bool &flag)
{
    qDebug() << Q_FUNC_INFO;

    m_avtStatus = flag;
    emit statusChange();
}

////// СЛОТЫ ВЫЗЫВАЕМЫЕ ИЗ NETWORK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void MainWindow::saveDataUser(const QString &login,
                              const QString &password,
                              const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    setLogin(login);
    m_keyword  = keyword;
    m_password = password;
    setStatus(true);
}

void MainWindow::clearDataUser()
{
    qDebug() << Q_FUNC_INFO;

    m_login.clear();
    m_keyword.clear();
    m_password.clear();
    m_server.clear();
    setStatus(false);
}

////// СЛОТЫ ВЫЗЫВАЕМЫЕ ИЗ QML
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void MainWindow::connect(const QString &address)
{
    qDebug() << Q_FUNC_INFO << address;

    setServer(address);
    emit connectTo(address);
}

void MainWindow::disconnect()
{
    qDebug() << Q_FUNC_INFO;

    emit disconnectTo();
}

void MainWindow::avtorizate(const QString &login,
                            const QString &password,
                            const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    emit avtorizateTo(login, password, keyword);
}

void MainWindow::registrate(const QString &login,
                            const QString &password,
                            const QString &keyword)
{
    qDebug() << Q_FUNC_INFO << login << password << keyword;

    emit registrateTo(login, password, keyword);
}

void MainWindow::exitAccount(const QString &login)
{
    qDebug() << Q_FUNC_INFO << login;

    emit exitAccountTo(login);
}

void MainWindow::message(const QString &to,
                         const QString &message)
{
    qDebug() << Q_FUNC_INFO << to << message;

    emit messageTo(m_login, to, message);
}

void MainWindow::loadHistoryPublic()
{
    qDebug() << Q_FUNC_INFO;

    emit loadHistoryPublicTo();
}

void MainWindow::loadHistoryPrivate(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    emit loadHistoryPrivateTo(to);
}

void MainWindow::updateContacts()
{
    qDebug() << Q_FUNC_INFO;

    emit updateContactTo();
}

void MainWindow::clearPrivateId()
{
    qDebug() << Q_FUNC_INFO;

    emit clearPrivateIdTo();
}

void MainWindow::call(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    m_reader.open(":/sounds/vibertone.wav");
    openSoundCard(false, false);

    emit callTo(to);
}

void MainWindow::asseptCall(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    closeSoundCard();
    openSoundCard(true, true);

    emit asseptTo(to);

    emit voiceTo();
}

void MainWindow::exitCall(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to;

    closeSoundCard();
    m_reader.open(":/sounds/no_answer.wav");
    openSoundCard(false, false);

    emit exitTo(to);

    emit timerStop();
}

void MainWindow::selectFile(const QString &filePath)
{
    qDebug() << Q_FUNC_INFO << handleFileChosen(filePath);

    m_currentFile = handleFileChosen(filePath);
    emit addFile(splitFilename(handleFileChosen(filePath)));
}

void MainWindow::clearFile()
{
    qDebug() << Q_FUNC_INFO << m_currentFile;

    m_currentFile.clear();

    qDebug() << Q_FUNC_INFO << m_currentFile;
}

void MainWindow::sendFile(const QString &to)
{
    qDebug() << Q_FUNC_INFO << to << m_currentFile;

    emit sendFileTo(to, m_currentFile);
}

////// Работа с звуковой картой
////////////////////////////////////////////////////////////////////////////////////////////////

void MainWindow::callbackWav(gsl::span<PortAudio::Sample>, gsl::span<PortAudio::Sample> dst)
{
    qDebug() << Q_FUNC_INFO;

    if (!m_reader.read(dst))
        closeSoundCard();
}

void MainWindow::callbackVoice(gsl::span<PortAudio::Sample> src, gsl::span<PortAudio::Sample> dst)
{
    qDebug() << Q_FUNC_INFO;

    m_ringBufferTo->write({(float*)src.data(), 2 * src.size()});

    if (m_ringBufferFrom.readCount() >= dst.size())
        m_ringBufferFrom.read( {(float*)dst.data(), dst.size()} );
}
