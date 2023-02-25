#pragma once
#include <QObject>
#include <QQmlApplicationEngine>
#include <QtCore>
#include <complex>
#include <mutex>

#include "PortAudioWraper/PortAudioWraper.h"
#include "WavReader/WavReader.h"
#include "Volume/Volume.h"
#include "Storage/Storage.h"
#include <QmlAqualizer.h>
#include "kissfftr.h"

#include <QtQuick/QQuickView>

class MainWindow : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentProgress READ getProgress WRITE setProgress NOTIFY testSignal)
    Q_PROPERTY(QString m_time READ getTime WRITE setTime NOTIFY timeChange)

public:
    explicit MainWindow(QObject *parent = nullptr);
    ~MainWindow();
    void show();

    using devices_t = std::vector<std::shared_ptr<PortAudio::Info>>;

    int getProgress() const;
    void setProgress(int value);

    QString getTime() const;
    void setTime(QString str);

signals:
    void testSignal();
    void timeChange();

    void notification(QString title, QString description);

public slots:

    Q_INVOKABLE void testOpen(bool checked, int indexInp, int indexOut);

    Q_INVOKABLE QStringList inputDevice() const;
    Q_INVOKABLE QStringList outputDevice() const;

    Q_INVOKABLE QString openFile(bool checked, QString file);
    Q_INVOKABLE bool closeFile(bool checked);

    Q_INVOKABLE QString test_setVolumeTarget(float value);
    Q_INVOKABLE QString currentVolume();

    Q_INVOKABLE void setPainter(Aqualizer2 *painter);

    void onDrawSpectrum();

private:
    QQmlApplicationEngine m_engine;

    devices_t m_inputs;
    devices_t m_output;
    std::unique_ptr<PortAudio::Device> pDevice;

    float m_phase {0};
    const float m_step {2*6.28f*700/48000.0f};

    WavReader m_wavReader;
    Volume m_volumeMain;
    Storage m_storage;

    QString m_fileName;

    kissr::dftr m_fft {256};

    std::vector<float> m_signal;
    std::vector<std::complex<float>> m_spectr;
    std::vector<float> m_power;

    std::mutex m_mutex;
    QTimer m_timer;

    QQuickView m_view;

    int currentProgress {0};
    QString m_time = "0:00 | 0:00";

    Aqualizer2 *m_painter {nullptr};

private:
    void callback(gsl::span<PortAudio::Sample>, gsl::span<PortAudio::Sample>);

};
