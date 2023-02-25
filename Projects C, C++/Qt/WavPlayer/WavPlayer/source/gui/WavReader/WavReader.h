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
     * \brief Возращает значение октрыт ли файл сейчас
     */
    bool isOpen() const;

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

    /**
     * \brief Возращает количество сэмплов в файле
     */
    int countSamples() const;

    /**
     * \brief Возращает количество прочитанных сэмплов
     */
    int countReadSamples() const;

    void setReadSamples(int count);

    void setSeekFile(int count);

    float durationSec() const;
    int durationMin() const;

    float percentSec() const;

private:
    struct impl;
    std::unique_ptr<impl> pImpl;
};

