INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

HEADERS += \
    $$PWD/impl/__kiss_fft_guts.h \
    $$PWD/impl/__kiss_fft.h \
    $$PWD/impl/__kiss_fftr.h \
    $$PWD/kissfftr.h

SOURCES += \
    $$PWD/impl/__kiss_fft.cpp \
    $$PWD/impl/__kiss_fftr.cpp \
    $$PWD/kissfftr.cpp
