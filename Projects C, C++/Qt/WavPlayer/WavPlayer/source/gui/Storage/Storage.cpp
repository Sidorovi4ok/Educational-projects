#include "Storage.h"
#include <QFile>
#include <QVariantMap>
#include <QJsonDocument>

Storage::Storage()
{

}

Storage::~Storage()
{

}

void Storage::saveSetting(int input, int output, float volume, QString file, int samples, bool flag) const
{
    QFile jsonStorage(fileStorage);
    jsonStorage.open(QIODevice::WriteOnly);

    QVariantMap infoMap;

    infoMap.insert("input",     input);
    infoMap.insert("output",    output);
    infoMap.insert("volume",    volume);
    infoMap.insert("file",      file);
    infoMap.insert("time",      samples);
    infoMap.insert("play",      flag);

    jsonStorage.write(QJsonDocument(QJsonObject::fromVariantMap(infoMap)).toJson());
    jsonStorage.close();
}

void Storage::loadSetting()
{
    QFile jsonStorage(fileStorage);
    jsonStorage.open(QIODevice::ReadOnly);

    QString data;
    data = jsonStorage.readAll();
    jsonStorage.close();

    QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
    json = doc.object();
}

