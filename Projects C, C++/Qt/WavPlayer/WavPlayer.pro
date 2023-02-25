QT += quick core

SOURCES += source/main.cpp

HEADERS += source/gui/MainWindow.h
SOURCES += source/gui/MainWindow.cpp

HEADERS += source/gui/PortAudioWraper/PortAudioWraper.h
SOURCES += source/gui/PortAudioWraper/PortAudioWraper.cpp

HEADERS += source/gui/Storage/Storage.h
SOURCES += source/gui/Storage/Storage.cpp

HEADERS += source/gui/Volume/Volume.h
SOURCES += source/gui/Volume/Volume.cpp

HEADERS += source/gui/WavReader/WavReader.h
SOURCES += source/gui/WavReader/WavReader.cpp

RESOURCES += resource/resource.qrc

include(libs/PortAudio/PortAudio.pri)
include(libs/gsl/gsl.pri)
include(libs/kiss_fftr/kissfftr.pri)
include(libs/QmlLibs/QmlLibs.pri)
