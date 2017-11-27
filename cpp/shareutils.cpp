// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "shareutils.hpp"

#ifdef Q_OS_IOS
#include "cpp/ios/iosshareutils.hpp"
#endif

#ifdef Q_OS_ANDROID
#include "cpp/android/androidshareutils.hpp"
#endif

ShareUtils::ShareUtils(QObject *parent)
    : QObject(parent)
{
#if defined(Q_OS_IOS)
    mPlatformShareUtils = new IosShareUtils(this);
#elif defined(Q_OS_ANDROID)
    mPlatformShareUtils = new AndroidShareUtils(this);
#else
    mPlatformShareUtils = new PlatformShareUtils(this);
#endif

    bool connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::shareEditDone, this, &ShareUtils::onShareEditDone);
    Q_ASSERT(connectResult);

    connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::shareFinished, this, &ShareUtils::onShareFinished);
    Q_ASSERT(connectResult);

    connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::shareNoAppAvailable, this, &ShareUtils::onShareNoAppAvailable);
    Q_ASSERT(connectResult);

    connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::shareError, this, &ShareUtils::onShareError);
    Q_ASSERT(connectResult);

    Q_UNUSED(connectResult);
}

void ShareUtils::share(const QString &text, const QUrl &url)
{
    mPlatformShareUtils->share(text, url);
}

void ShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    mPlatformShareUtils->sendFile(filePath, title, mimeType, requestId);
}

void ShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    mPlatformShareUtils->viewFile(filePath, title, mimeType, requestId);
}

void ShareUtils::editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    mPlatformShareUtils->editFile(filePath, title, mimeType, requestId);
}

void ShareUtils::onShareEditDone(int requestCode)
{
    emit shareEditDone(requestCode);
}

void ShareUtils::onShareFinished(int requestCode)
{
    emit shareFinished(requestCode);
}

void ShareUtils::onShareNoAppAvailable(int requestCode)
{
    emit shareNoAppAvailable(requestCode);
}

void ShareUtils::onShareError(int requestCode, QString message)
{
    emit shareError(requestCode, message);
}

