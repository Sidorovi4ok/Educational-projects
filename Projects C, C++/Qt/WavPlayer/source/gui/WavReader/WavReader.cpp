#include "WavReader.h"

int readWav(const QString filename, QString filenameToSave=QString()) {

    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        return 0;
    }

    quint32 chunkDataSize = 0;

    QByteArray temp_buff;
    char buff[0x04];
    while (true) {
        QByteArray tmp = file.read(0x04);
        temp_buff.append(tmp);
        int idx = temp_buff.indexOf("data");
        if (idx >= 0) {
            int lenOfData = temp_buff.length() - (idx + 4);
            memcpy(buff, temp_buff.constData() + idx + 4, lenOfData);
            int bytesToRead = 4 - lenOfData;
            if (bytesToRead > 0) {
                int read = file.read(buff + lenOfData, bytesToRead);
                if (bytesToRead != read) {
                    qDebug() << "smf wrong";
                    return 0;
                }
            }
            chunkDataSize = qFromLittleEndian<quint32>((const uchar*)buff);
            break;
        }
        if (temp_buff.length() >= 8){
            temp_buff.remove(0, 0x04);
        }
    }
    if (!chunkDataSize) {
        qDebug() << "not found";
        return 0;
    }

    int smp = 0;
    QFile saveFile(filenameToSave);

    if (!saveFile.open(QIODevice::WriteOnly))
        qDebug() << saveFile.errorString();

    while (file.read(buff, 0x04) > 0) {
        chunkDataSize -= 4;
        ++smp;

        if (saveFile.isOpen()) {
            saveFile.write(buff, 0x04);
        }

        if (chunkDataSize == 0 || chunkDataSize & 0x80000000) {
            break;
        }
    }

    file.close();
    if (saveFile.isOpen()) {
        saveFile.close();
    }

    return smp;
}

struct Sample16s {
    qint16 left;
    qint16 right;
};

inline float int16toFloat(quint16 value) {
    static constexpr float K = 1.0/0x80FF;
    return K*static_cast<float>(value);
}

inline PortAudio::Sample sample16toFloat(Sample16s value) {
    static constexpr float K = 1.0/0x80FF;
    return {K*static_cast<float>(value.left), K*static_cast<float>(value.right)};
}

inline convert(gsl::span<quint16> src, gsl::span<float> dst) {
    std::transform(src.begin(), src.end(), dst.begin(), [](auto value) {
       return int16toFloat(value);
    });
}

inline convert(gsl::span<Sample16s> src, gsl::span<PortAudio::Sample> dst) {
    std::transform(src.begin(), src.end(), dst.begin(), [](auto value) {
       return sample16toFloat(value);
    });
}

struct WavReader::impl {

    struct wav_header_t
    {
        char            chunkID[4]; //"RIFF" = 0x46464952
        unsigned long   chunkSize; //28 [+ sizeof(wExtraFormatBytes) + wExtraFormatBytes] + sum(sizeof(chunk.id) + sizeof(chunk.size) + chunk.size)
        char            format[4]; //"WAVE" = 0x45564157
        char            subchunk1ID[4]; //"fmt " = 0x20746D66
        unsigned long   subchunk1Size; //16 [+ sizeof(wExtraFormatBytes) + wExtraFormatBytes]
        unsigned short  audioFormat;
        unsigned short  numChannels;
        unsigned long   sampleRate;
        unsigned long   byteRate;
        unsigned short  blockAlign;
        unsigned short  bitsPerSample;
        char            ID[4]; //"data" = 0x61746164
        unsigned long   size;  //Chunk data bytes
    };

    impl() {

    }

    ~impl() {

    }

    bool open(const QString &fileName_src)
    {
        if (!openned) {
            fileWav.setFileName(fileName_src);
            if (fileWav.open(QIODevice::ReadOnly)) {
                qDebug() << "\nFile is open!" << fileName_src;
                openned = true;

                fileWav.read((char*)&header_t, sizeof(wav_header_t));

                // Вывод информации о заголовке WAV файла
                qDebug() << "WAV File Header read:\n";
                qDebug() << "File Type: "                                   << header_t.chunkID;
                qDebug() << "File Size: "                                   << header_t.chunkSize;
                qDebug() << "WAV Marker: "                                  << header_t.format;
                qDebug() << "Format Name: "                                 << header_t.subchunk1ID;
                qDebug() << "Format Length: "                               << header_t.subchunk1Size;
                qDebug() << "Format Type: "                                 << header_t.audioFormat;
                qDebug() << "Number of Channels: "                          << header_t.numChannels;
                qDebug() << "Sample Rate: "                                 << header_t.sampleRate;
                qDebug() << "Sample Rate * Bits/Sample * Channels / 8: "    << header_t.byteRate;
                qDebug() << "Bits per Sample * Channels / 8.1: "            << header_t.blockAlign;
                qDebug() << "Bits per Sample: "                             << header_t.bitsPerSample;

                sampleRate_t = header_t.sampleRate;

                // Чтение и запись сэмплов в файл, возвращает кол-во сэмплов
                fileSamples_t.setFileName("../WavPlayer/saveSamples.txt");

                if (fileSamples_t.open(QIODevice::ReadOnly))
                {
                    m_countSamples =  readWav(fileName_src, "../WavPlayer/saveSamples.txt");
                    qDebug() << "Count samples: "                           << m_countSamples;

                    float sec = 1.f * header_t.size / (header_t.bitsPerSample / 8) / header_t.numChannels / header_t.sampleRate;

                    m_percentSec = sec / 100;

                    int min = (int) floor(sec) / 60;
                    sec = floor(sec - (min * 60));

                    m_durationSec = sec;
                    m_durationMin = min;
                }
                else
                {
                    qDebug() << "File with samples is not open!" << fileSamples_t.errorString();
                    return false;
                }
                return true;
            }
        }
        qDebug() << "\nFile is not open!" << fileName_src << fileWav.errorString();
        return false;
    }

    void close()
    {
        if (openned) {
            qDebug() << "File is close";
            fileWav.close();
            openned = false;
            m_readSamples = 0;
            fileSamples_t.seek(0);
            fileSamples_t.close();
        }
        else {
            qDebug() << "File already close";
        }
    }

    bool isOpen() const
    {
        if (openned) {
            return true;
        }
        return false;
    }

    quint32 sampleRate() const
    {
        return sampleRate_t;
    }

    quint32 channels() const
    {
        return channels_t;
    }

    bool read(gsl::span<PortAudio::Sample> dst)
    {
        if (isOpen())
        {
            if (fileSamples_t.atEnd())
            {
                fileSamples_t.seek(0);
                m_readSamples = 0;
            }

            m_data.resize(dst.size());
            fileSamples_t.read((char*)m_data.data(), sizeof(Sample16s)*dst.size());
            convert(m_data,dst);
            m_readSamples += dst.size();
            return true;
        }

        else
        {
            qDebug() << "File is not open now";
            return false;
        }
    }

    int countSamples() const {
        return m_countSamples;
    }

    int countReadSamples() const {
        return m_readSamples;
    }

    int durationMin() const {
        return m_durationMin;
    }

    float durationSec() const {
        return m_durationSec;
    }

    float percentSec() const {
        return m_percentSec;
    }

    void setReadSamples(int count) {
        m_readSamples = count;
    }

    void setSeekFile(int count) {
        fileSamples_t.seek(count * 4);
    }

private:
    QFile fileWav;
    QFile fileSamples_t;

    wav_header_t header_t;

    quint32 sampleRate_t;
    quint32 channels_t;

    int m_durationMin {0};
    float m_durationSec {0};

    int m_countSamples;
    int m_readSamples {0};

    float m_percentSec;

    std::vector<Sample16s> m_data;

    bool openned = false;
};


WavReader::WavReader()
    : pImpl{std::make_unique<impl>()}
{

}

WavReader::~WavReader() {

}

bool WavReader::open(const QString &fileName_src)
{
    return pImpl->open(fileName_src);
}

void WavReader::close()
{
    return pImpl->close();
}

bool WavReader::isOpen() const
{
    return pImpl->isOpen();
}

quint32 WavReader::sampleRate() const
{
    return pImpl->sampleRate();
}

quint32 WavReader::channels() const
{
    return pImpl->channels();
}

bool WavReader::read(gsl::span<PortAudio::Sample> dst)
{
    return pImpl->read(dst);
}

int WavReader::countSamples() const
{
    return pImpl->countSamples();
}

int WavReader::countReadSamples() const
{
    return pImpl->countReadSamples();
}

void WavReader::setReadSamples(int count)
{
    return pImpl->setReadSamples(count);
}

void WavReader::setSeekFile(int count)
{
    return pImpl->setSeekFile(count);
}

int WavReader::durationMin() const
{
    return pImpl->durationMin();
}

float WavReader::durationSec() const
{
    return pImpl->durationSec();
}

float WavReader::percentSec() const
{
    return pImpl->percentSec();
}
