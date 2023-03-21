DEPENDPATH  += $$PWD
INCLUDEPATH += $$PWD

HEADERS += $$PWD/opus/opus.h
HEADERS += $$PWD/opus/opus_custom.h
HEADERS += $$PWD/opus/opus_defines.h
HEADERS += $$PWD/opus/opus_multistream.h
HEADERS += $$PWD/opus/opus_projection.h
HEADERS += $$PWD/opus/opus_types.h

HEADERS += $$PWD/copus.h
SOURCES += $$PWD/copus.cpp

win32 {
    contains(QT_ARCH, i386) {
        LIBS += -L$$PWD/libs/win32/msvc/ -lopus
        DISTFILES += $$PWD/libs/win32/msvc/opus.lib
    }
    else {
        LIBS += -L$$PWD/libs/win64/msvc/ -lopus
        DISTFILES += $$PWD/libs/win64/msvc/opus.lib
    }
}
linux {
    LIBS += -lopus
}
macx {
    LIBS += -L$$PWD/libs/macx/ -lopus
    DISTFILES += $$PWD/libs/macx/libopus.a
}

