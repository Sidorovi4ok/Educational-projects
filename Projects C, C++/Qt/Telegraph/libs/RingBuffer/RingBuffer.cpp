#include "RingBuffer.h"
#include <QDebug>

RingBuffer::RingBuffer()
{

}

void RingBuffer::resize(std::size_t sample)
{
    if (m_buffer.size() != sample) {
        m_buffer.resize(sample);
        clear();
    }
}

std::size_t RingBuffer::size() const
{
    return m_buffer.size();
}

std::size_t RingBuffer::readCount()
{
    return m_readCount;
}

std::size_t RingBuffer::writeCount()
{
    return m_writeCount;
}

bool RingBuffer::write(gsl::span<float> src)
{
    if (m_writeCount < src.size() || src.empty())
        return false;

    // Вычисляем кол-во сэмплов до конца
    const auto t_distance = std::distance(m_buffer.begin() + m_writePos, m_buffer.end());

    if (t_distance >= src.size())
    {
        std::copy(src.begin(), src.end(), m_buffer.begin() + m_writePos);
    }
    else
    {
        std::copy_n(src.begin(), t_distance, m_buffer.begin() + m_writePos);
        std::copy(src.begin() + t_distance, src.end(), m_buffer.begin());
    }

    m_writePos = (m_writePos + src.size()) % m_buffer.size();

    m_writeCount -= src.size();
    m_readCount  += src.size();

    return true;
}

bool RingBuffer::read(gsl::span<float> dst)
{
    if (m_readCount < dst.size())
        return false;

    // Вычисляем кол-во сэмплов до конца
    const auto t_distance = std::distance(m_buffer.begin() + m_readPos, m_buffer.end());

    if (t_distance >= dst.size())
    {
        std::copy(m_buffer.begin() + m_readPos, m_buffer.begin() + m_readPos + dst.size(), dst.begin());
    }
    else
    {
        std::copy_n(m_buffer.begin() + m_readPos, t_distance, dst.begin());
        std::copy(m_buffer.begin(), m_buffer.begin() + (dst.size() -  t_distance), dst.begin() + t_distance);
    }

    m_readPos = (m_readPos + dst.size()) % m_buffer.size();

    m_readCount  -= dst.size();
    m_writeCount += dst.size();

    return true;
}

void RingBuffer::clear()
{
    m_writeCount = m_buffer.size();
    m_readCount  = 0;
    m_writePos   = 0;
    m_readPos    = 0;
}
