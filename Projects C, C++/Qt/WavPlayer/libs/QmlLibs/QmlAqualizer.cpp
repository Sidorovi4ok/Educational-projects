#include "QmlAqualizer.h"
#include <QPainter>

Aqualizer2::Aqualizer2(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void Aqualizer2::setPower(gsl::span<float> power)
{
    m_powerA.resize(power.size());
    std::transform(power.begin(), power.end(), m_powerA.begin(), [](float value) {
        return -1 * value;
    });
}

void Aqualizer2::write(gsl::span<float> src)
{
    m_samples.resize(src.size());
    std::transform(src.begin(), src.end(), m_samples.begin(), [](float value) {
        return -1 * value;
    });
}

void Aqualizer2::paint(QPainter *painter)
{
    QColor colorLine(Qt::white);
    QPen pen = QPen(colorLine);

    pen.setWidth(2);
    painter->setPen(pen);

    painter->translate(0, 135);
    painter->rotate(180);
    painter->scale(-1.0, 1.0);
    painter->scale(1, 0.5);

    if (m_samples.empty())
    {
        for (int i = 0, startX {25}; i < 128; ++i, startX +=5) {
            painter->drawLine(QLine(startX, 0, startX, 4));
        }
        return;
    }

    for (int i = 128, startX {25}; i > 0; --i, startX +=5) {
        painter->drawLine(QLine(startX, 0, startX, m_samples[i].get()));
    }
    painter->end();
}
