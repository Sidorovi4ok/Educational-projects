#pragma once
#include <QtCore>
#include <gsl>
#include "../PortAudioWraper/PortAudioWraper.h"

class WavReader
{
public:
    WavReader();
    ~WavReader();

    /**
     * \brief Возращает булевое значение, что wav файл открыт, возращает txt файл с записанными сэмплами
     * \param fileName_src - входящий wav файл
     * \param fileName_dst - создающийся txt файл с записанными сэмплами
     */
    bool open(const QString &fileName_src);

    /**
     * \brief Закрытие wav файла
     */
    void close();

    /**
     * \brief Возращает частоту дискретизации
     */
    quint32 sampleRate() const;

    /**
     * \brief Возращает количество каналов
     */
    quint32 channels() const;

    /**
     * \brief Читает блок сэмплов
     */
    bool read(gsl::span<PortAudio::Sample> dst);

private:
    struct impl;
    std::unique_ptr<impl> pImpl;
};

