#include "Volume.h"

Volume::Volume()
{

}

Volume::~Volume()
{

}

float Volume::smooth(float alpha)
{
    return m_volumeTarget*alpha + m_volume*(1.0f - alpha);
}

void Volume::setVolume(float newValume)
{
    m_volume = newValume;
}

void Volume::setVolumeTarget(float newValumeTarget)
{
    m_volumeTarget = newValumeTarget;
}

float Volume::getVolume() const
{
    return m_volume;
}

float Volume::getVolumeTarget() const
{
    return m_volumeTarget;
}
