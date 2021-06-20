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

 CONFIG += debug_and_release

OTHER_FILES += data_assets/*.png \
    data_assets/*.pdf \
    translations/*.* \
    *.md \
    ios/*.png \
    docs/*.png \
    LICENSE \
    COPYRIGHT

# can be placed under ios only, but I prefer to see them always
OTHER_FILES += ios/src/*.mm

# can be placed under android only, but I prefer to see them always
OTHER_FILES += android/src/org/ekkescorner/utils/QShareUtils.java \
    android/src/org/ekkescorner/examples/sharex/QShareActivity.java \
    android/src/org/ekkescorner/utils/QSharePathResolver.java

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
    android/res/values/libs.xml \
    android/res/xml/filepaths.xml \
    android/build.gradle \
    data_assets/ekke.jpg

android {
    QT += androidextras

    SOURCES += cpp/android/androidshareutils.cpp

    HEADERS += cpp/android/androidshareutils.hpp

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

ios {
    OBJECTIVE_SOURCES += ios/src/iosshareutils.mm \
    ios/src/docviewcontroller.mm

    HEADERS += cpp/ios/iosshareutils.hpp \
    cpp/ios/docviewcontroller.hpp

    QMAKE_INFO_PLIST = ios/Info.plist

    QMAKE_IOS_DEPLOYMENT_TARGET = 12.0

    disable_warning.name = GCC_WARN_64_TO_32_BIT_CONVERSION
    disable_warning.value = NO
    QMAKE_MAC_XCODE_SETTINGS += disable_warning

    # see https://bugreports.qt.io/browse/QTCREATORBUG-16968
    # ios_signature.pri not part of project repo because of private signature details
    # contains:
    # QMAKE_XCODE_CODE_SIGN_IDENTITY = "iPhone Developer"
    # MY_DEVELOPMENT_TEAM.name = DEVELOPMENT_TEAM
    # MY_DEVELOPMENT_TEAM.value = your team Id from Apple Developer Account
    # QMAKE_MAC_XCODE_SETTINGS += MY_DEVELOPMENT_TEAM

    include(ios_signature.pri)

    MY_BUNDLE_ID.name = PRODUCT_BUNDLE_IDENTIFIER
    MY_BUNDLE_ID.value = org.ekkescorner.share_example_x
    QMAKE_MAC_XCODE_SETTINGS += MY_BUNDLE_ID

    # Note for devices: 1=iPhone, 2=iPad, 1,2=Universal.
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
}
