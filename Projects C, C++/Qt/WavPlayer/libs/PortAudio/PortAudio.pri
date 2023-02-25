INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

HEADERS += $$PWD/portaudio.h

windows {
    contains(QT_ARCH, i386) {
        LIBS += -L$$PWD/windows/x32/ -lportaudio_x86
        PRE_TARGETDEPS += $$PWD/windows/x32/portaudio_x86.lib
    }
    else {
        LIBS += -L$$PWD/windows/x64/ -lportaudio_x64
        PRE_TARGETDEPS += $$PWD/windows/x64/portaudio_x64.lib
    }
}
linux {
    LIBS += -L$$PWD/linux/ -lportaudio
    LIBS += -lrt -lm -lasound -ljack
}
macx {
    LIBS += -L$$PWD/macOS/ -lportaudio
    LIBS += -framework CoreAudio -framework AudioToolbox -framework AudioUnit -framework CoreServices -framework Carbon
    PRE_TARGETDEPS += $$PWD/macOS/libportaudio.a
}

