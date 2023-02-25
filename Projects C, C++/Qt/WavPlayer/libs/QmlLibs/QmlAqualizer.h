#pragma once

#include <QtQuick/QQuickPaintedItem>
#include <vector>
#include <span>

class Aqualizer2 : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    static constexpr quint32 Count {50};

    struct Sample {

        Sample& operator=(float value) {
            set(value);
            return *this;
        }

        void set(float value)
        {
            if (value > m_value)
            {
                m_value = value;
                m_count = 0;
            }

            if (value < m_value) {
                if (m_count < Count)
                {
                    ++m_count;
                }

                else
                {
                    m_value = smooth(60, m_value);
                }
            }
        }

        float get() const {
            return m_value;
        }

        private:
            inline float smooth(float newValue, float oldValue, float alpha = 0.95)
            {
                return oldValue*alpha + newValue*(1.0f - alpha);
            }

        private:
            float m_value {-60.0f};
            quint32 m_count {0};
    };

public:
    Aqualizer2(QQuickItem *parent = nullptr);

    void setPower(gsl::span<float> power);

    void write(gsl::span<float> src);

    void paint(QPainter *painter) override;

private:
    std::vector<float> m_powerA;
    std::vector<Sample> m_samples;

};

