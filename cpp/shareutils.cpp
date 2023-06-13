// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "shareutils.hpp"
#include <QFileInfo>
#include <QUrl>

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

    connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::fileUrlReceived, this, &ShareUtils::onFileUrlReceived);
    Q_ASSERT(connectResult);

    connectResult = connect(mPlatformShareUtils, &PlatformShareUtils::fileReceivedAndSaved, this, &ShareUtils::onFileReceivedAndSaved);
    Q_ASSERT(connectResult);

    Q_UNUSED(connectResult);
}

bool ShareUtils::checkMimeTypeView(const QString &mimeType)
{
    return mPlatformShareUtils->checkMimeTypeView(mimeType);
}

bool ShareUtils::checkMimeTypeEdit(const QString &mimeType)
{
    return mPlatformShareUtils->checkMimeTypeEdit(mimeType);
}

void ShareUtils::share(const QString &text, const QUrl &url)
{
    mPlatformShareUtils->share(text, url);
}

void ShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId, const bool &altImpl)
{
    mPlatformShareUtils->sendFile(filePath, title, mimeType, requestId, altImpl);
}

void ShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId, const bool &altImpl)
{
    mPlatformShareUtils->viewFile(filePath, title, mimeType, requestId, altImpl);
}

void ShareUtils::editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId, const bool &altImpl)
{
    mPlatformShareUtils->editFile(filePath, title, mimeType, requestId, altImpl);
}

void ShareUtils::checkPendingIntents(const QString workingDirPath)
{
    mPlatformShareUtils->checkPendingIntents(workingDirPath);
}

// testing native FileDialog
bool ShareUtils::verifyFileUrl(const QString &fileUrl)
{
#if defined(Q_OS_ANDROID)
    QFileInfo fileInfo(fileUrl);
    qDebug() << "verifying fileUrl: " << fileUrl;
    qDebug() << "BASE: " << fileInfo.baseName();
    return fileInfo.exists();
#endif
#if defined(Q_OS_IOS)
    qDebug() << "verify iOS File from assets-library " << fileUrl;

    QUrl url(fileUrl);
    QString iosFile = url.toLocalFile();
    qDebug() << "converted to LocaleFile: " << iosFile;

    QFileInfo theFile(iosFile);

    if (!theFile.exists()) {
        qWarning("iOS File does N O T exist");
        return false;
    }
    qDebug("Path from QML: The file E X I S T S");
    if (theFile.isReadable()) {
        qDebug("iosFile SUCCESS: can open file for reading");
        return true;
    }  else {
        qWarning("iosFile FAILS: can NOT open file for reading");
    }
    return false;
#endif
    // not used yet for other OS
    return false;
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

void ShareUtils::onFileUrlReceived(QString url)
{
    emit fileUrlReceived(url);
}

void ShareUtils::onFileReceivedAndSaved(QString url)
{
    emit fileReceivedAndSaved(url);
}

