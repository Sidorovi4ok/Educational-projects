#pragma once

class Volume
{
public:
    Volume();
    ~Volume();

public:
    float smooth (float alpha);

    void setVolume(float newValume);
    void setVolumeTarget(float newValumeTarget);

    float getVolume() const;
    float getVolumeTarget() const;

private:
    float m_volume {1};
    float m_volumeTarget {0.5};
};
