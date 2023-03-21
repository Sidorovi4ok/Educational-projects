#include "copus.h"
#include "opus/opus.h"

#include <QDebug>

struct destroyer
{
    void operator()(OpusEncoder *p) {
        opus_encoder_destroy(p);
    }

    void operator()(OpusDecoder *p) {
        opus_decoder_destroy(p);
    }
};

using EncoderPtr = std::unique_ptr<OpusEncoder, destroyer>;
using DecoderPtr = std::unique_ptr<OpusDecoder, destroyer>;

namespace opus {

struct encoder::impl {
public:
    impl(){}

    bool init(std::uint32_t sampleRate, std::uint32_t channels, AudioMode mode)
    {
        int err = OPUS_OK;

        pEncoder.reset(opus_encoder_create(sampleRate,
                                           channels,
                                           (mode == AudioMode::VoIP) ? OPUS_APPLICATION_VOIP : OPUS_APPLICATION_AUDIO,
                                           &err));
        m_channels = channels;
        return (err == OPUS_OK && pEncoder);
    }

    bool isInit() const
    {
        return pEncoder ? true : false;
    }

    bool setBitrate(int bps)
    {
        return opus_encoder_ctl(pEncoder.get(), OPUS_SET_BITRATE(bps) == OPUS_OK);
    }

    gsl::span<std::uint8_t> procces(gsl::span<float> src, gsl::span<std::uint8_t> dst)
    {
        auto bytes = opus_encode_float(pEncoder.get(), src.data(), src.size() / m_channels, dst.data(), dst.size());

        if (bytes > 0)
            return gsl::span<std::uint8_t> {dst.data(), std::size_t(bytes)};
        return {};
    }

private:
    EncoderPtr pEncoder;
    int m_channels {0};

};

encoder::encoder() : pImpl{std::make_unique<impl>()}
{

}

encoder::~encoder() = default;

bool encoder::init(uint32_t sampleRate, uint32_t channels, AudioMode mode)
{
    return pImpl->init(sampleRate, channels, mode);
}

bool encoder::isInit() const
{
    return pImpl->isInit();
}

bool encoder::setBitrate(int bps)
{
    return pImpl->setBitrate(bps);
}

gsl::span<std::uint8_t> encoder::procces(gsl::span<float> src, gsl::span<uint8_t> dst)
{
    return pImpl->procces(src, dst);
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



struct decoder::impl {
public:
    impl(){}

    bool init(std::uint32_t sampleRate, std::uint32_t channels)
    {
        int err = OPUS_OK;
        pDecoder.reset(opus_decoder_create(sampleRate, channels, &err));
        m_channels = channels;
        return (err == OPUS_OK && pDecoder);
    }

    bool isInit() const
    {
        return pDecoder ? true : false;
    }

    gsl::span<float> procces(gsl::span<std::uint8_t> src, gsl::span<float> dst)
    {
        auto samples = opus_decode_float(pDecoder.get(), src.data(), src.size() / m_channels, dst.data(), dst.size(), 0);
        if (samples > 0)
            return gsl::span{dst.data(), std::size_t(samples)};
        return {};
    }

private:
    DecoderPtr pDecoder;
    int m_channels {0};

};

decoder::decoder() : pImpl{std::make_unique<impl>()}
{

}

decoder::~decoder() = default;

bool decoder::init(uint32_t sampleRate, uint32_t channels)
{
    return pImpl->init(sampleRate, channels);
}

bool decoder::isInit() const
{
    return pImpl->isInit();
}

gsl::span<float> decoder::procces(gsl::span<uint8_t> src, gsl::span<float> dst)
{
    return pImpl->procces(src, dst);
}

}
