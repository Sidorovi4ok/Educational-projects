#include "kissfftr.h"
#include <algorithm>
#include "impl/__kiss_fftr.h"

namespace kissr {

struct dftr::impl
{
    impl(std::size_t fft_size) {
        resize(fft_size);
    }
    ~impl() {}

    bool resize(std::size_t value) {
        if (m_size == value)
            return true;

        m_size = value;
        if (m_size == 0)
            return true;

        // инициализация прямого преобразования
        size_t t_memSize {0};
        kiss_fftr_alloc(static_cast<int>(m_size), 0, nullptr, &t_memSize);
        m_memForward.resize(t_memSize);
        m_cfgForward = kiss_fftr_alloc(static_cast<int>(m_size), 0, m_memForward.data(), &t_memSize);

        // инициализация обратного преобразования
        kiss_fftr_alloc(static_cast<int>(m_size), 1, nullptr, &t_memSize);
        m_memBackward.resize(t_memSize);
        m_cfgBackward = kiss_fftr_alloc(static_cast<int>(m_size), 1, m_memBackward.data(), &t_memSize);

        return (m_cfgForward != nullptr) && (m_cfgBackward != nullptr);
    }

    std::size_t size() const {
        return m_size;
    }

    bool forward(const gsl::span<float> src, gsl::span<std::complex<float>> dst) {
        if ((m_cfgForward != nullptr) && (src.size() == m_size) && (dst.size() == m_size)) {
            // вычисляем прямое преобразование Фурье
            kiss_fftr(m_cfgForward, src.data(), reinterpret_cast<kiss_fft_cpx*>(dst.data()));
            return true;
        }
        return false;
    }

    bool backword(const gsl::span<std::complex<float>> src, gsl::span<float> dst) {
        if ((m_cfgBackward != nullptr) && (src.size() == m_size) && (dst.size() == m_size)) {
            // вычисляем прямое преобразование Фурье
            kiss_fftri(m_cfgBackward, (const kiss_fft_cpx*)src.data(), dst.data());
            return true;
        }
        return false;
    }

private:
    std::size_t   m_size {0};
    kiss_fftr_cfg m_cfgForward  {nullptr};
    kiss_fftr_cfg m_cfgBackward {nullptr};
    std::vector<uint8_t> m_memForward;
    std::vector<uint8_t> m_memBackward;
};

dftr::dftr(std::size_t fft_size)
    : pImpl{std::make_unique<impl>(fft_size)}
{

}

dftr::~dftr()
{

}

bool dftr::resize(std::size_t value)
{
    return pImpl->resize(value);
}

std::size_t dftr::size() const
{
    return pImpl->size();
}

bool dftr::forward(const gsl::span<float> src, gsl::span<std::complex<float>> dst)
{
    return pImpl->forward(src, dst);
}

bool dftr::backword(const gsl::span<std::complex<float>> src, gsl::span<float> dst)
{
    return pImpl->backword(src, dst);
}
}
