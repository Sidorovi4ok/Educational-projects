#pragma once

#include <QString>
#include <QJsonObject>

class Storage
{
public:
    Storage();
    ~Storage();

public:
    void saveSetting(int input, int output, float volume, QString file, int samples, bool flag) const;
    void loadSetting() ;

public:
    QString fileStorage = "Settings.json";
    QJsonObject json;
};

