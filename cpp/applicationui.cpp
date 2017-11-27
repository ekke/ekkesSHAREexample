// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "applicationui.hpp"

#include <QtQml>
#include <QGuiApplication>

#include <QFile>
#include <QDir>

#include <QDebug>

const QString IMAGE_DATA_FILE = "/qt-logo.png";
const QString IMAGE_ASSETS_FILE_PATH = ":/data_assets/qt-logo.png";
const QString PDF_DATA_FILE = "/share_file.pdf";
const QString PDF_ASSETS_FILE_PATH = ":/data_assets/share_file.pdf";

const static int NO_RESPONSE_IMAGE = 0;
// const static int NO_RESPONSE_PDF = -1;
const static int EDIT_FILE_IMAGE = 42;
// const static int EDIT_FILE_PDF = 44;
const static int VIEW_FILE_IMAGE = 22;
// const static int VIEW_FILE_PDF = 21;
const static int SEND_FILE_IMAGE = 11;
//const static int SEND_FILE_PDF = 10;

ApplicationUI::ApplicationUI(QObject *parent) : QObject(parent), mShareUtils(new ShareUtils(this))
{
    // this is a demo application where we deal with an Image and a PDF as example
    // Image and PDF are delivered as qrc:/ resources at /data_assets
    // to start the tests as first we must copy these 2 files from assets into APP DATA
    // so we can simulate HowTo view, edit or send files from inside your APP DATA to other APPs
    // in a real life app you'll have your own workflows
    // I made copyAssetsToAPPData() INVOKABLE to be able to reset to origin files
    copyAssetsToAPPData();
}

void ApplicationUI::addContextProperty(QQmlContext *context)
{
    context->setContextProperty("shareUtils", mShareUtils);
}

void ApplicationUI::copyAssetsToAPPData() {
    // Android: HomeLocation works, iOS: not writable - so I'm using always QStandardPaths::AppDataLocation
    // Android: AppDataLocation works out of the box, iOS you must create the DIR first !!
    QString appDataRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
    // QString appDataRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
    qDebug() << "QStandardPaths::AppDataLocation: " << appDataRoot;
#if defined (Q_OS_IOS)
    if (!QDir(appDataRoot).exists()) {
        if (QDir("").mkpath(appDataRoot)) {
            qDebug() << "Created app data directory. " << appDataRoot;
        } else {
            qWarning() << "Failed to create app data directory. " << appDataRoot;
            return;
        }
    }
#endif
    // as next we create a /my_share_files subdirectory
    mAppDataFilesPath = appDataRoot.append("/my_share_files");
    if (!QDir(mAppDataFilesPath).exists()) {
        if (QDir("").mkpath(mAppDataFilesPath)) {
            qDebug() << "Created app data /files directory. " << mAppDataFilesPath;
        } else {
            qWarning() << "Failed to create app data /files directory. " << mAppDataFilesPath;
            return;
        }
    }
    // now copy files from assets to APP DATA /my_share_files
    // if not existing
    if(!QFile::exists(mAppDataFilesPath+IMAGE_DATA_FILE)) {
        bool copied = copyAssetFile(IMAGE_ASSETS_FILE_PATH, mAppDataFilesPath+IMAGE_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the Image from Assets to APP DATA";
    }
    if(!QFile::exists(mAppDataFilesPath+PDF_DATA_FILE)) {
        bool copied = copyAssetFile(PDF_ASSETS_FILE_PATH, mAppDataFilesPath+PDF_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the PDF from Assets to APP DATA";
    }
    // now create working dir in Documents Location if not exists
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
    qDebug() << "QStandardPaths::DocumentsLocation: " << docLocationRoot;
    mDocumentsWorkPath = docLocationRoot.append("/share_example_x_files");
    if (!QDir(mDocumentsWorkPath).exists()) {
        if (QDir("").mkpath(mDocumentsWorkPath)) {
            qDebug() << "Created Documents Location work directory. " << mDocumentsWorkPath;
        } else {
            qWarning() << "Failed to create Documents Location work directory. " << mDocumentsWorkPath;
            return;
        }
    }
    qDebug() << "Documents Location work directory exists: " << mDocumentsWorkPath;
}

bool ApplicationUI::copyAssetFile(const QString sourceFilePath, const QString destinationFilePath) {
    if (QFile::exists(destinationFilePath))
    {
        bool removed = QFile::remove(destinationFilePath);
        if(!removed) {
            qWarning() << "Failed to remove " << destinationFilePath;
            return false;
        }
    }
    bool copied = QFile::copy(sourceFilePath, destinationFilePath);
    if(!copied) {
        qWarning() << "Failed to copy " << sourceFilePath << " to " << destinationFilePath;
        return false;
    }
    // because files are copied from assets it's a good idea to set r/w permissions
    bool permissionsSet = QFile(destinationFilePath).setPermissions(QFileDevice::ReadUser | QFileDevice::WriteUser);
    if(!permissionsSet) {
        qDebug() << "cannot set Permissions to read / write settings for " << destinationFilePath;
        return false;
    }
    return true;
}

// Data files in AppDataLocation cannot shared with other APPs
// so we copy them into our working directory inside USERS DOCUMENTS location
//
QString ApplicationUI::filePathDocumentsLocation(const int requestId) {
    QString sourceFilePath;
    QString destinationFilePath;
    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
        sourceFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
    } else {
        sourceFilePath = mAppDataFilesPath+PDF_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
    }
    if (QFile::exists(destinationFilePath))
    {
        bool removed = QFile::remove(destinationFilePath);
        if(!removed) {
            qWarning() << "Failed to remove " << destinationFilePath;
            return destinationFilePath;
        }
    }
    bool copied = QFile::copy(sourceFilePath, destinationFilePath);
    if(!copied) {
        qWarning() << "Failed to copy " << sourceFilePath << " to " << destinationFilePath;
    }
    return destinationFilePath;
}

bool ApplicationUI::deleteFromDocumentsLocation(const int requestId) {
    QString filePath;
    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
        filePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
    } else {
        filePath = mDocumentsWorkPath+PDF_DATA_FILE;
    }
    if (QFile::exists(filePath)) {
        bool removed = QFile::remove(filePath);
        if(!removed) {
            qWarning() << "Failed to remove " << filePath;
            return false;
        }
    } else {
        qWarning() << "No file to delete found: " << filePath;
        return false;
    }
    qDebug() << "File removed from Documents Location: " << filePath;
    return true;
}

bool ApplicationUI::updateFileFromDocumentsLocation(const int requestId) {
    QString docLocationFilePath;
    QString appDataFilePath;
    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
        docLocationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
    } else {
        docLocationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+PDF_DATA_FILE;
    }
    if (QFile::exists(docLocationFilePath)) {
        // delete appDataFilePath should exist
        if(QFile::exists(appDataFilePath)) {
            bool removed = QFile::remove(appDataFilePath);
            if(!removed) {
                qWarning() << "Failed to remove " << appDataFilePath;
                // go on
            } else {
                qDebug() << "old file removed: " << appDataFilePath;
            }
        }
        // now copy the file from doc location to app data location
        bool copied = QFile::copy(docLocationFilePath, appDataFilePath);
        if(!copied) {
            qWarning() << "Failed to copy " << docLocationFilePath << " to " << appDataFilePath;
            return false;
        } else {
            qDebug() << "successfully replaced " << appDataFilePath << " from " << docLocationFilePath;
            // now delete from Documents location
            bool removed = QFile::remove(docLocationFilePath);
            if(!removed) {
                qWarning() << "Failed to remove " << docLocationFilePath;
                // go on
            } else {
                qDebug() << "doc file removed: " << docLocationFilePath;
            }
        }
    } else {
        qWarning() << "No file to update from found: " << docLocationFilePath;
        return false;
    }
    return true;
}

void ApplicationUI::setShareState(const bool isShareActive, const bool isEditActive, const int requestCode)
{
    qDebug() << "set share state. active ?" << isShareActive << " edit ? " << isEditActive;
    mShareActive = isShareActive;
    mShareEditActive = isEditActive;
    mShareRequestCode = requestCode;
}

#if defined(Q_OS_ANDROID)
void ApplicationUI::onApplicationStateChanged(Qt::ApplicationState applicationState)
{
    qDebug() << "S T A T E changed into: " << applicationState;
    if(applicationState == Qt::ApplicationState::ApplicationSuspended) {
        // nothing to do
        return;
    }
    if(applicationState == Qt::ApplicationState::ApplicationActive) {
        if(mShareActive) {
            qDebug() << "I am back";
            // we're back from the external App
            if(mShareEditActive) {
                // important to know that edit was done:
                // edited file must be copied back into APP Data !
                mShareUtils->onShareEditDone(mShareRequestCode);
            } else {
                mShareUtils->onShareFinished(mShareRequestCode);
            }
            mShareEditActive = false;
            mShareActive = false;
            mShareRequestCode = 0;
        }
    }
}
#endif
