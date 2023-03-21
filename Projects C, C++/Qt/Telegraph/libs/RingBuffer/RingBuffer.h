#pragma once

#include <cstddef>
#include <span>
#include <vector>

class RingBuffer
{
public:
    RingBuffer();

    void resize(std::size_t sample);

    std::size_t size() const;
    std::size_t writeCount();
    std::size_t readCount();

    bool write(gsl::span<float> src);
    bool read (gsl::span<float> dst);
    void clear();

private:
    std::vector<float> m_buffer;

    // Готовых для записи сэмплов
    size_t m_writeCount {0};
    size_t m_writePos   {0};

    // Готовых для чтения сэмплов
    size_t m_readCount  {0};
    size_t m_readPos    {0};
};

