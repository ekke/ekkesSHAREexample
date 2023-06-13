# ekke (Ekkehard Gentz) @ekkescorner
TEMPLATE = app
TARGET = share_example_x

QT += qml quick quickcontrols2

CONFIG += c++11

HEADERS += cpp/shareutils.hpp \
    cpp/applicationui.hpp

SOURCES += cpp/main.cpp \
    cpp/shareutils.cpp \
    cpp/applicationui.cpp

OTHER_FILES +=  qml/main.qml

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
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/res/xml/filepaths.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    data_assets/ekke.jpg

android {
    QT += androidextras
    SOURCES += cpp/android/androidshareutils.cpp
    HEADERS += cpp/android/androidshareutils.hpp
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    # deploying 32-bit and 64-bit APKs you need different VersionCode
    # here's my way to solve this - per ex. Version 1.2.3
    # aabcddeef aa: 21 (MY_MIN_API), b: 0 (32 Bit) or 1 (64 Bit)  c: 0 (unused)
    # dd: 01 (Major Release), ee: 02 (Minor Release), f:  3 (Patch Release)
    # VersionName 1.2.3
    # VersionCode 32 Bit: 210001023
    # VersionCode 64 Bit: 211001023
    # Version App Bundles: 212001023
    defineReplace(droidVersionCode) {
        segments = $$split(1, ".")
        for (segment, segments): vCode = "$$first(vCode)$$format_number($$segment, width=2 zeropad)"
        equals(ANDROID_ABIS, arm64-v8a): \
            prefix = 1
        else: equals(ANDROID_ABIS, armeabi-v7a): \
            prefix = 0
        else: prefix = 2
        # add more cases as needed
        return($$first(prefix)0$$first(vCode))
    }
    MY_VERSION = 1.2
    MY_PATCH_VERSION = 0
    MY_MIN_API = 21
    ANDROID_VERSION_NAME = $$MY_VERSION"."$$MY_PATCH_VERSION
    ANDROID_VERSION_CODE = $$MY_MIN_API$$droidVersionCode($$MY_VERSION)$$MY_PATCH_VERSION

    # find this in shadow build android-build gradle.properties
    ANDROID_MIN_SDK_VERSION = "21"
    ANDROID_TARGET_SDK_VERSION = "31"
}

ios {
    LIBS += -framework Photos

    OBJECTIVE_SOURCES += ios/src/iosshareutils.mm \
    ios/src/docviewcontroller.mm

    HEADERS += cpp/ios/iosshareutils.hpp \
    cpp/ios/docviewcontroller.hpp

    QMAKE_INFO_PLIST = ios/Info.plist

    QMAKE_IOS_DEPLOYMENT_TARGET = 12.0

    disable_warning.name = GCC_WARN_64_TO_32_BIT_CONVERSION
    disable_warning.value = NO
    QMAKE_MAC_XCODE_SETTINGS += disable_warning

    # don't need this anymore
    # now QtCreator can set iOS development team from iOS Build Settings
    # include(ios_signature.pri)

    MY_BUNDLE_ID.name = PRODUCT_BUNDLE_IDENTIFIER
    MY_BUNDLE_ID.value = org.ekkescorner.share_example_x
    QMAKE_MAC_XCODE_SETTINGS += MY_BUNDLE_ID

    # Note for devices: 1=iPhone, 2=iPad, 1,2=Universal.
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
}
