#pragma once
#include <cstdint>
#include <complex>
#include <memory>
#include <span>

namespace kissr {
class dftr {
public:
    explicit dftr(std::size_t fft_size = 0);
    ~dftr();

    bool resize(std::size_t value);
    std::size_t size() const;

    bool forward(const gsl::span<float> src, gsl::span<std::complex<float>> dst);
    bool backword(const gsl::span<std::complex<float>> src, gsl::span<float> dst);

private:
    struct impl;
    std::unique_ptr<impl> pImpl;
};
}
