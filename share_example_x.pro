# ekke (Ekkehard Gentz) @ekkescorner
TEMPLATE = app
TARGET = share_example_x

QT += qml quick core

CONFIG += c++11

HEADERS += cpp/shareutils.hpp \
    cpp/applicationui.hpp

SOURCES += cpp/main.cpp \
    cpp/shareutils.cpp \
    cpp/applicationui.cpp

lupdate_only {
    SOURCES +=  qml/main.qml
}

OTHER_FILES += data_assets/*.png \
    data_assets/*.pdf \
    translations/*.* \
    *.md \
    ios/*.png \
    docs/*.png \
    LICENSE \
    COPYRIGHT

RESOURCES += qml.qrc \
    data_assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

android {
    QT += androidextras

    SOURCES += cpp/android/androidshareutils.cpp

    HEADERS += cpp/android/androidshareutils.hpp

    OTHER_FILES += android/src/org/ekkescorner/utils/QShareUtils.java

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

ios {
    OBJECTIVE_SOURCES += ios/src/iosshareutils.mm \
    ios/src/docviewcontroller.mm

    HEADERS += cpp/ios/iosshareutils.hpp \
    cpp/ios/docviewcontroller.hpp

    QMAKE_IOS_DEPLOYMENT_TARGET = 8.2

    disable_warning.name = GCC_WARN_64_TO_32_BIT_CONVERSION
    disable_warning.value = NO
    QMAKE_MAC_XCODE_SETTINGS += disable_warning

    # Note for devices: 1=iPhone, 2=iPad, 1,2=Universal.
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
}
