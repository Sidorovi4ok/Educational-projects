#include <QtGlobal>
#include <QString>
#include <vector>
#include <memory>
#include <functional>
#include <span>

#pragma once

class PortAudio
{
public:
    struct Sample {
        float left;
        float right;

        Sample& operator* (float value) {
            left *= value;
            right *= value;
            return *this;
        }
    };

    using callback_t = std::function<void(gsl::span<Sample>,
                                          gsl::span<Sample>)>;

    enum class Type {
        Playback,
        Record
    };

    class Info {
    public:
        Info() {}

        /**
         * \brief возвращает тип устройства.
         */
        virtual Type type() const = 0;

        /**
         * \brief возращает максимальное количество каналов.
         */
        virtual quint32 maxChannels() const = 0;

        /**
         * \brief возращает частоту дискретизации по умолчанию.
         */
        virtual quint32 defaultSampleRate() const = 0;

        /**
         * \brief Возращает драйвер устройства.
         */
        virtual QString driver() const = 0;

        /**
         * \brief Возращает имя устройства.
         */
        virtual QString name() const = 0;
    };

    class Device {
    public:
        Device() {};
        virtual ~Device(){}

        virtual bool open(std::shared_ptr<Info> input,
                          std::shared_ptr<Info> output,
                          quint32 sampleRate,
                          quint32 blockSize,
                          callback_t callback) = 0;

        virtual void close() = 0;

        virtual bool isOpen() const = 0;
    };

public:
    ~PortAudio();
    static PortAudio& instance();

    /**
     * \brief Возращает список обнаруженных устройств.
     * \param type - тип устройства
     */
    std::vector<std::shared_ptr<Info>> discover(Type type) const;

    /**
     * \brief Возращает новый экземпляр устройства.
     */
    std::unique_ptr<Device> create() const;

    std::shared_ptr<Info> defaultInputDevice()  const;
    std::shared_ptr<Info> defaultOutputDevice() const;

private:
    PortAudio();
};
