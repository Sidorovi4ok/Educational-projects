#include "PortAudioWraper.h"
#include <portaudio.h>
#include <QDebug>
#include <QString>


class DeviceInfo final : public PortAudio::Info {
public:
    DeviceInfo(const DeviceInfo &) = default;

    DeviceInfo(
            PortAudio::Type type,
            quint32 channels,
            quint32 sampleRate,
            const QString &driver,
            const QString &name,
            const PaHostApiInfo *hostInfo,
            const PaDeviceInfo *deviceInfo,
            quint32 deviceIndex,
            double latency)
        : m_type {type},
          m_maxChannels {channels},
          m_defaultSampleRate {sampleRate},
          m_driver {driver},
          m_name {name},
          pHostInfo {hostInfo},
          pDeviceInfo {deviceInfo},
          m_deviceIndex {deviceIndex},
          m_latency {latency}
    {

    }

    PortAudio::Type type() const override {
        return m_type;
    }

    quint32 maxChannels() const override {
        return m_maxChannels;
    }

    quint32 defaultSampleRate() const override {
        return m_defaultSampleRate;
    }

    QString driver() const override {
        return m_driver;
    }

    QString name() const override {
        return m_name;
    }

    const PaHostApiInfo* hostInfo() const {
        return pHostInfo;
    }

    const PaDeviceInfo* deviceInfo() const {
        return pDeviceInfo;
    }

    quint32 deviceIndex() const {
        return m_deviceIndex;
    }

    double latency() const {
        return m_latency;
    }

private:
    PortAudio::Type m_type {PortAudio::Type::Playback};
    quint32 m_maxChannels {0};
    quint32 m_defaultSampleRate {0};
    QString m_driver;
    QString m_name;
    const PaHostApiInfo *pHostInfo;
    const PaDeviceInfo *pDeviceInfo;
    quint32 m_deviceIndex {0};
    double m_latency {0.0};
};

class PaDevice : public PortAudio::Device {
public:
    PaDevice() {

    }

    ~PaDevice() override {
        close();
    }

    bool open(std::shared_ptr<PortAudio::Info> input,
              std::shared_ptr<PortAudio::Info> output,
              quint32 sampleRate,
              quint32 blockSize,
              PortAudio::callback_t callback) override
    {
        if (m_open)
            return false;

        if (!callback)
            return false;

        m_callback = callback;

        if (input) {
            pInputParameters = std::make_unique<PaStreamParameters>();
            auto pInfo = reinterpret_cast<DeviceInfo*>(input.get());
            pInputParameters->device = pInfo->deviceIndex();
            pInputParameters->channelCount = 2;
            pInputParameters->sampleFormat = paFloat32;
            pInputParameters->suggestedLatency = pInfo->latency();
            pInputParameters->hostApiSpecificStreamInfo = nullptr;
        }

        if (output) {
            pOutputParameters = std::make_unique<PaStreamParameters>();
            auto pInfo = reinterpret_cast<DeviceInfo*>(output.get());
            pOutputParameters->device = pInfo->deviceIndex();
            pOutputParameters->channelCount = 2;
            pOutputParameters->sampleFormat = paFloat32;
            pOutputParameters->suggestedLatency = pInfo->latency();
            pOutputParameters->hostApiSpecificStreamInfo = nullptr;
        }

        if (const auto status = Pa_OpenStream(&pStream,
                                              pInputParameters.get(),
                                              pOutputParameters.get(),
                                              sampleRate,
                                              blockSize,
                                              paNoFlag,
                                              &PaDevice::callback,
                                              this);
            status != paNoError)
        {
            pInputParameters.reset();
            pOutputParameters.reset();
            return false;
        }

        if (const auto status = Pa_StartStream(pStream); status != paNoError) {
            Pa_CloseStream(pStream);
            pInputParameters.reset();
            pOutputParameters.reset();
            return false;
        }
        m_open = true;
        return m_open;
    }

    void close() override {
        if (m_open) {
            Pa_StopStream(pStream);
            Pa_CloseStream(pStream);
            pInputParameters.reset();
            pOutputParameters.reset();
            m_open = false;
        }
    }

    bool isOpen() const override {
        return m_open;
    }

private:
    static int callback(const void*                     inputBuffer,
                        void*                           outputBuffer,
                        unsigned long                   framesPerBuffer,
                        const PaStreamCallbackTimeInfo* timeInfo,
                        PaStreamCallbackFlags           statusFlags,
                        void*                           userData)
    {

        reinterpret_cast<PaDevice*>(userData)->procces((float*)inputBuffer,
                                                       (float*)outputBuffer,
                                                       framesPerBuffer);
        return paNoError;
    }

    void procces(float *src, float *dst, quint32 samples) {
        m_callback(src != nullptr ? gsl::span{(PortAudio::Sample*)src, samples} : gsl::span<PortAudio::Sample> {},
                   dst != nullptr ? gsl::span{(PortAudio::Sample*)dst, samples} : gsl::span<PortAudio::Sample> {});
    }

private:
    PaStream* pStream {nullptr};
    std::unique_ptr<PaStreamParameters>  pInputParameters;
    std::unique_ptr<PaStreamParameters>  pOutputParameters;
    bool m_open {false};
    PortAudio::callback_t m_callback;
};



PortAudio::PortAudio()
{
    qDebug() << Q_FUNC_INFO;
    Pa_Initialize();
}

PortAudio::~PortAudio()
{
    qDebug() << Q_FUNC_INFO;
    Pa_Terminate();
}

PortAudio &PortAudio::instance()
{
    qDebug() << Q_FUNC_INFO;
    static PortAudio t_instance;
    return t_instance;
}

std::vector<std::shared_ptr<PortAudio::Info> > PortAudio::discover(Type type) const
{
    std::vector<std::shared_ptr<PortAudio::Info>> t_vector;

    // проходим по всем доступным драйверам
    for (PaHostApiIndex driver {0}; driver < Pa_GetHostApiCount(); ++driver) {
        // получаем информацию о доступных устройствах
        auto pHostInfo = Pa_GetHostApiInfo(driver);
        // извлекаем список устройств
        for (PaDeviceIndex device {0}; device < pHostInfo->deviceCount; ++device) {
            // получаем номер устройства в системе
            auto deviceIndex = Pa_HostApiDeviceIndexToDeviceIndex(driver, device);
            // извлекаем ифнормацию об устройстве
            auto pDeviceInfo = Pa_GetDeviceInfo(deviceIndex);

            if (type == Type::Playback) {
                if (pDeviceInfo->maxOutputChannels > 0) {
                    t_vector.push_back(std::make_shared<DeviceInfo>(type,
                                                                    pDeviceInfo->maxOutputChannels,
                                                                    pDeviceInfo->defaultSampleRate,
                                                                    QString::fromUtf8(pHostInfo->name),
                                                                    QString::fromUtf8(pDeviceInfo->name),
                                                                    pHostInfo,
                                                                    pDeviceInfo,
                                                                    deviceIndex,
                                                                    pDeviceInfo->defaultLowOutputLatency));
                }
            }
            else if (type == Type::Record) {
                if (pDeviceInfo->maxInputChannels > 0) {
                    t_vector.push_back(std::make_shared<DeviceInfo>(type,
                                                                    pDeviceInfo->maxOutputChannels,
                                                                    pDeviceInfo->defaultSampleRate,
                                                                    QString::fromUtf8(pHostInfo->name),
                                                                    QString::fromUtf8(pDeviceInfo->name),
                                                                    pHostInfo,
                                                                    pDeviceInfo,
                                                                    deviceIndex,
                                                                    pDeviceInfo->defaultLowInputLatency));
                }
            }
        }
    }
    return t_vector;
}

std::unique_ptr<PortAudio::Device> PortAudio::create() const
{
    return std::make_unique<PaDevice>();
}


std::shared_ptr<PortAudio::Info> PortAudio::defaultInputDevice() const
{
    PaHostApiIndex driver = Pa_GetDefaultHostApi();
    auto pHostInfo = Pa_GetHostApiInfo(driver);

    PaDeviceIndex deviceIndex = pHostInfo->defaultInputDevice;
    auto pDeviceInfo = Pa_GetDeviceInfo(deviceIndex);

    auto test = std::make_shared<DeviceInfo>(PortAudio::Type::Playback,
                                 pDeviceInfo->maxOutputChannels,
                                 pDeviceInfo->defaultSampleRate,
                                 QString::fromUtf8(pHostInfo->name),
                                 QString::fromUtf8(pDeviceInfo->name),
                                 pHostInfo,
                                 pDeviceInfo,
                                 deviceIndex,
                                 pDeviceInfo->defaultLowOutputLatency);

    return std::shared_ptr<PortAudio::Info>(test);
}

std::shared_ptr<PortAudio::Info> PortAudio::defaultOutputDevice() const
{
    PaHostApiIndex driver = Pa_GetDefaultHostApi();
    auto pHostInfo = Pa_GetHostApiInfo(driver);

    PaDeviceIndex deviceIndex = pHostInfo->defaultOutputDevice;
    auto pDeviceInfo = Pa_GetDeviceInfo(deviceIndex);

    auto test = std::make_shared<DeviceInfo>(PortAudio::Type::Playback,
                                 pDeviceInfo->maxOutputChannels,
                                 pDeviceInfo->defaultSampleRate,
                                 QString::fromUtf8(pHostInfo->name),
                                 QString::fromUtf8(pDeviceInfo->name),
                                 pHostInfo,
                                 pDeviceInfo,
                                 deviceIndex,
                                 pDeviceInfo->defaultLowOutputLatency);

    return std::shared_ptr<PortAudio::Info>(test);
}
