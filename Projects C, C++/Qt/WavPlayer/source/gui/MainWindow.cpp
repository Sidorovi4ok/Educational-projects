#include "MainWindow.h"
#include <QGuiApplication>
#include <QQmlContext>

QString handleFileChosen(const QString &urlString) {
    const QUrl url(urlString);
    if (url.isLocalFile()) {
        return(QDir::toNativeSeparators(url.toLocalFile()));
    } else {
        return(urlString);
    }
}

// Идиома RAII
struct Locker
{
    Locker() = delete;
    Locker(std::mutex &mut) : m_mutex{mut} { m_mutex.lock(); }
    ~Locker() { m_mutex.unlock(); }

private:
    std::mutex &m_mutex;
};

MainWindow::MainWindow(QObject *parent)
    : QObject{parent}
{
    m_signal.resize(m_fft.size());
    m_spectr.resize(m_fft.size());
    m_power.resize(m_fft.size());

    m_output = PortAudio::instance().discover(PortAudio::Type::Playback);
    m_inputs = PortAudio::instance().discover(PortAudio::Type::Record);

    m_inputs.insert(m_inputs.begin(), {});
    m_output.insert(m_output.begin(), {});

    pDevice = PortAudio::instance().create();

    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
                     qGuiApp, [](QObject *obj, const QUrl &) {
        if (!obj)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    QObject::connect(&m_timer, &QTimer::timeout, this, &MainWindow::onDrawSpectrum);

    m_engine.rootContext()->setContextProperty("mainWindow", this);
}

MainWindow::~MainWindow()
{
    pDevice->close();
    m_wavReader.close();
}

void MainWindow::show()
{
    const QUrl url("qrc:/qml/main.qml");
    m_engine.load(url);
}

int MainWindow::getProgress() const
{
    return currentProgress;
}

void MainWindow::setProgress(int value)
{
    currentProgress = value;
    emit testSignal();
}

QString MainWindow::getTime() const
{
    return m_time;
}

void MainWindow::setTime(QString str)
{
    m_time = str;
    emit timeChange();
}

void MainWindow::testOpen(bool checked, int indexInp, int indexOut)
{
    if ( checked )
    {
        if (!m_fileName.isEmpty())
            m_wavReader.open(m_fileName);

        if (!pDevice->open(m_inputs.at(indexInp),
                           m_output.at(indexOut),
                           (!m_fileName.isEmpty()) ? m_wavReader.sampleRate() : 44100,
                           m_fft.size(),
                           std::bind(&MainWindow::callback,
                                     this,
                                     std::placeholders::_1,
                                     std::placeholders::_2)))
        {
            emit notification("Ошибка PortAudio", "Не удалось открыть устройство");
            pDevice->close();
            return;
        }
        m_timer.start(12);
    }
    else
    {
        pDevice->close();
    }
}

QStringList MainWindow::inputDevice() const
{
    QStringList t_list;

    t_list.append("Не используется");

    std::transform(m_inputs.begin(), m_inputs.end(),
                   std::back_inserter(t_list),
                   [](auto &info)->QString
    {
        if (info)
            return info->name();
        return "";
    });

    return t_list;
}

QStringList MainWindow::outputDevice() const
{
    QStringList t_list;

    t_list.append("Не используется");

    std::transform(m_output.begin(), m_output.end(),
                   std::back_inserter(t_list),
                   [](auto &info)->QString
    {
        if (info)
            return info->name();
        return "";
    });

    return t_list;
}

QString MainWindow::openFile(bool checked, QString file)
{
    if (!checked)
    {
        if (!file.isEmpty())
        {
            m_fileName = handleFileChosen(file);
            qDebug() << m_fileName;
        }
    }
    else {
        emit notification("Ошибка выбора файла", "Закройте устройства для выбора нового файла");
    }
    return m_fileName;
}

bool MainWindow::closeFile(bool checked)
{
    if (!checked)
    {
        m_wavReader.close();
        m_fileName = NULL;
        return true;
    }
    else
    {
        emit notification("Ошибка выбора файла", "Закройте устройства для выбора нового файла");
        return false;
    }
}

QString MainWindow::test_setVolumeTarget(float value)
{
    m_volumeMain.setVolumeTarget(value);
    return QString::number(int(value * 100));
}

QString MainWindow::currentVolume()
{
    return QString::number(int(m_volumeMain.getVolumeTarget() * 100));
}

void MainWindow::setPainter(Aqualizer2 *painter)
{
    m_painter = painter;
}

void MainWindow::onDrawSpectrum()
{
    // RAII
    {
        std::lock_guard locker {m_mutex};
        m_fft.forward(m_signal, m_spectr);
    }

    std::transform(m_spectr.begin(), m_spectr.end(), m_power.begin(),
                   [&](std::complex<float> sample)
    {
        return 20*std::log(std::abs(sample) + 1.0e-7);
    });

    if (m_wavReader.countReadSamples() != 0 && !m_fileName.isEmpty())
    {
        setProgress(int(float((m_wavReader.countReadSamples()) / float(m_wavReader.countSamples())) * 100));

        if (m_painter != nullptr)
        {
            m_painter->write(m_power);
            m_painter->update();
        }
    }
}

void MainWindow::callback(gsl::span<PortAudio::Sample>src, gsl::span<PortAudio::Sample>dst)
{
    qDebug() << Q_FUNC_INFO;

    if (!m_fileName.isEmpty())
    {
        m_wavReader.setSeekFile(m_wavReader.countReadSamples());
        m_wavReader.read(dst);

        float sec = m_wavReader.percentSec() * (float(m_wavReader.countReadSamples()) / float(m_wavReader.countSamples()) * 100);
        int min = (int)floor(sec) / 60;
        sec = floor(sec - (min * 60));

        QString tmp_time = QString::number(min) + ":" +
                           QString::number(sec) + " | " +
                           QString::number(m_wavReader.durationMin()) + ":" +
                           QString::number(m_wavReader.durationSec());

        setTime(tmp_time);

        // RAII
        {
            if(!dst.empty()) {
                std::lock_guard locker {m_mutex};
                std::transform(dst.begin(), dst.end(), m_signal.begin(),
                               [&](PortAudio::Sample sample)
                {
                    return sample.left;
                });
            }
        }

        std::transform(dst.begin(), dst.end(), dst.begin(),
                       [&](PortAudio::Sample sample)
        {
            m_volumeMain.setVolume(m_volumeMain.smooth(0.99));
            return sample * m_volumeMain.getVolume();
        });
    }

    else
    {
        if (!src.empty()|| !dst.empty())
        {
            std::transform(src.begin(), src.end(), dst.begin(),
                           [&](PortAudio::Sample sample)
            {
                m_volumeMain.setVolume(m_volumeMain.smooth(0.99));
                sample.left = std::sin(m_phase) * m_volumeMain.getVolume();
                sample.right = sample.left;
                m_phase += m_step;
                return sample;
            });
            m_phase = std::fmod(m_step, 2*M_PI);
        }
    }
}



