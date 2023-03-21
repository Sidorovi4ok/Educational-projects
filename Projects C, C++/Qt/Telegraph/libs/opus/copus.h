#pragma once

#include <cstddef>
#include <cstdint>
#include <span>
#include <memory>

namespace opus
{
    enum class AudioMode {
        VoIP,
        Audio,
        LowDelay
    };

    class encoder
    {
        public:
            encoder();
            ~encoder();

            // Инициализация
            bool init(std::uint32_t sampleRate, std::uint32_t channels, AudioMode mode);
            bool isInit() const;
            bool setBitrate(int bps);

            // Возвращает количество сэмплов в dst
            gsl::span<std::uint8_t> procces(gsl::span<float> src, gsl::span<std::uint8_t> dst);

        private:
            struct impl;
            std::unique_ptr<impl> pImpl;
    };

    class decoder
    {
        public:
            decoder();
            ~decoder();

            bool init(std::uint32_t sampleRate, std::uint32_t channels);
            bool isInit() const;

            gsl::span<float> procces(gsl::span<std::uint8_t> src, gsl::span<float> dst);

        private:
            struct impl;
            std::unique_ptr<impl> pImpl;
    };
}
