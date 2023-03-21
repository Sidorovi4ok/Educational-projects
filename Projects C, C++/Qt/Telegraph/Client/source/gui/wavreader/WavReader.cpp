#include "WavReader.h"

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

    struct wav_header
    {
        char                RIFF[4];        // RIFF Header      Magic header
        unsigned long       ChunkSize;      // RIFF Chunk Size
        char                WAVE[4];        // WAVE Header
        char                fmt[4];         // FMT header
        unsigned long       Subchunk1Size;  // Size of the fmt chunk
        unsigned short      AudioFormat;    // Audio format 1=PCM,6=mulaw,7=alaw, 257=IBM Mu-Law, 258=IBM A-Law, 259=ADPCM
        unsigned short      NumOfChan;      // Number of channels 1=Mono 2=Sterio
        unsigned long       SamplesPerSec;  // Sampling Frequency in Hz
        unsigned long       bytesPerSec;    // bytes per second
        unsigned short      blockAlign;     // 2=16-bit mono, 4=16-bit stereo
        unsigned short      bitsPerSample;  // Number of bits per sample
        char                Subchunk2ID[4]; // "data"  string
        unsigned long       Subchunk2Size;  // Sampled data length
    };

    impl() {

    }

    ~impl() {

    }

    bool open(const QString &fileName_src)
    {
        m_fileWav.setFileName(fileName_src);
        if (m_fileWav.open(QIODevice::ReadOnly))
        {
            m_fileWav.read((char*)&m_header, sizeof(m_header));
            m_sampleRate   = m_header.SamplesPerSec;
            return true;
        }
        else {
            qDebug() << m_fileWav.errorString();
            return false;
        }
    }

    void close()
    {
        if (m_fileWav.isOpen()) {
            qDebug() << "File is close";
            m_fileWav.close();
        }
    }

    quint32 sampleRate() const
    {
        return m_sampleRate;
    }

    quint32 channels() const
    {
        return m_channels;
    }

    bool read(gsl::span<PortAudio::Sample> dst)
    {
        if (m_fileWav.isOpen())
        {
            if (m_fileWav.atEnd())
                return false;

            m_data.resize(dst.size());
            m_fileWav.read((char*)m_data.data(), sizeof(Sample16s)*dst.size());
            convert(m_data,dst);
            return true;
        }
        else
        {
            qDebug() << "File is not open now";
            return false;
        }
    }

private:
    QFile m_fileWav;
    wav_header m_header;

    quint32 m_sampleRate;
    quint32 m_channels;

    std::vector<Sample16s> m_data;
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
