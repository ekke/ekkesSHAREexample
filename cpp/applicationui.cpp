// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "applicationui.hpp"

#include <QtQml>
#include <QGuiApplication>

#include <QFile>
#include <QDir>

#include <QDebug>

#if defined(Q_OS_ANDROID)
#include <QtAndroid>
#endif

const QString IMAGE_DATA_FILE = "/qt-logo.png";
const QString IMAGE_ASSETS_FILE_PATH = ":/data_assets/qt-logo.png";

const QString JPEG_DATA_FILE = "/crete.jpg";
const QString JPEG_ASSETS_FILE_PATH = ":/data_assets/crete.jpg";

const QString DOCX_DATA_FILE = "/test.docx";
const QString DOCX_ASSETS_FILE_PATH = ":/data_assets/test.docx";

const QString PDF_DATA_FILE = "/share_file.pdf";
const QString PDF_ASSETS_FILE_PATH = ":/data_assets/share_file.pdf";

const static int NO_RESPONSE_IMAGE = 0;
const static int NO_RESPONSE_PDF = -1;
const static int NO_RESPONSE_JPEG = -2;
const static int NO_RESPONSE_DOCX = -3;

const static int EDIT_FILE_IMAGE = 42;
const static int EDIT_FILE_PDF = 44;
const static int EDIT_FILE_JPEG = 45;
const static int EDIT_FILE_DOCX = 46;

const static int VIEW_FILE_IMAGE = 22;
const static int VIEW_FILE_PDF = 21;
const static int VIEW_FILE_JPEG = 23;
const static int VIEW_FILE_DOCX = 24;

const static int SEND_FILE_IMAGE = 11;
const static int SEND_FILE_PDF = 10;
const static int SEND_FILE_JPEG = 12;
const static int SEND_FILE_DOCX = 13;

ApplicationUI::ApplicationUI(QObject *parent) : QObject(parent), mShareUtils(new ShareUtils(this)), mPendingIntentsChecked(false)
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
    // as next we create a /my_share_files subdirectory to store our example files from assets
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
    // in real-world app you would download files from a server or so
    if(!QFile::exists(mAppDataFilesPath+IMAGE_DATA_FILE)) {
        bool copied = copyAssetFile(IMAGE_ASSETS_FILE_PATH, mAppDataFilesPath+IMAGE_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the Image (PNG) from Assets to APP DATA";
    }
    if(!QFile::exists(mAppDataFilesPath+JPEG_DATA_FILE)) {
        bool copied = copyAssetFile(JPEG_ASSETS_FILE_PATH, mAppDataFilesPath+JPEG_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the Image (JPEG) from Assets to APP DATA";
    }
    if(!QFile::exists(mAppDataFilesPath+DOCX_DATA_FILE)) {
        bool copied = copyAssetFile(DOCX_ASSETS_FILE_PATH, mAppDataFilesPath+DOCX_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the Document (DOCX) from Assets to APP DATA";
    }
    if(!QFile::exists(mAppDataFilesPath+PDF_DATA_FILE)) {
        bool copied = copyAssetFile(PDF_ASSETS_FILE_PATH, mAppDataFilesPath+PDF_DATA_FILE);
        if(!copied) {
            return;
        }
        qDebug() << "copied the PDF from Assets to APP DATA";
    }
    // to provide files to other apps we're using a specific folder
    // version 1 of this example used QStandardPaths::DocumentsLocation on Android and iOS
    // iOS: QStandardPaths::DocumentsLocation points to: <APPROOT>/Documents - so it's inside the sandbox
    // Android: QStandardPaths::DocumentsLocation points to: <USER>/Documents outside the app sandbox
    // this worked while using FileUrl (SDK 23)
    // Android > SDK 23 needs a FileProvider providing a contentUrl
    // FileProvider uses Paths (see android/res/xml/filepaths.xml) stored at QStandardPaths::AppDataLocation

    // now create the working dir if not exists
#if defined (Q_OS_IOS)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
    qDebug() << "iOS: QStandardPaths::DocumentsLocation: " << docLocationRoot;
#elif defined(Q_OS_ANDROID)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
    qDebug() << "Android: QStandardPaths::AppDataLocation: " << docLocationRoot;
#else
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
#endif
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

// the old workflow (SDK 23, FilePath):
// Data files in AppDataLocation cannot shared with other APPs
// so we copy them into our working directory inside USERS DOCUMENTS location

// the new workflow:
// now with FileProvider our working directory is inside AppDataLocation
QString ApplicationUI::filePathDocumentsLocation(const int requestId) {
    QString sourceFilePath;
    QString destinationFilePath;
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        sourceFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        sourceFilePath = mAppDataFilesPath+JPEG_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        sourceFilePath = mAppDataFilesPath+DOCX_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        break;
    default:
        sourceFilePath = mAppDataFilesPath+PDF_DATA_FILE;
        destinationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
        break;
    }
//    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
//        sourceFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
//        destinationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
//    } else {
//        sourceFilePath = mAppDataFilesPath+PDF_DATA_FILE;
//        destinationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
//    }
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
//#if defined(Q_OS_ANDROID)
//        emit noDocumentsWorkLocation();
//#endif
    }
    return destinationFilePath;
}

bool ApplicationUI::deleteFromDocumentsLocation(const int requestId) {
    QString filePath;
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        filePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        filePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        filePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        break;
    default:
        filePath = mDocumentsWorkPath+PDF_DATA_FILE;
        break;
    }
//    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
//        filePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
//    } else {
//        filePath = mDocumentsWorkPath+PDF_DATA_FILE;
//    }
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
    switch (requestId) {
    case SEND_FILE_IMAGE:
    case VIEW_FILE_IMAGE:
    case EDIT_FILE_IMAGE:
    case NO_RESPONSE_IMAGE:
        docLocationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
        break;
    case SEND_FILE_JPEG:
    case VIEW_FILE_JPEG:
    case EDIT_FILE_JPEG:
    case NO_RESPONSE_JPEG:
        docLocationFilePath = mDocumentsWorkPath+JPEG_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+JPEG_DATA_FILE;
        break;
    case SEND_FILE_DOCX:
    case VIEW_FILE_DOCX:
    case EDIT_FILE_DOCX:
    case NO_RESPONSE_DOCX:
        docLocationFilePath = mDocumentsWorkPath+DOCX_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+DOCX_DATA_FILE;
        break;
    default:
        docLocationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
        appDataFilePath = mAppDataFilesPath+PDF_DATA_FILE;
        break;
    }
//    if(requestId == SEND_FILE_IMAGE || requestId == VIEW_FILE_IMAGE || requestId == EDIT_FILE_IMAGE || requestId == NO_RESPONSE_IMAGE) {
//        docLocationFilePath = mDocumentsWorkPath+IMAGE_DATA_FILE;
//        appDataFilePath = mAppDataFilesPath+IMAGE_DATA_FILE;
//    } else {
//        docLocationFilePath = mDocumentsWorkPath+PDF_DATA_FILE;
//        appDataFilePath = mAppDataFilesPath+PDF_DATA_FILE;
//    }
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

#if defined(Q_OS_ANDROID)
void ApplicationUI::onApplicationStateChanged(Qt::ApplicationState applicationState)
{
    qDebug() << "S T A T E changed into: " << applicationState;
    if(applicationState == Qt::ApplicationState::ApplicationSuspended) {
        // nothing to do
        return;
    }
    if(applicationState == Qt::ApplicationState::ApplicationActive) {
        // if App was launched from VIEW or SEND Intent
        // there's a race collision: the event will be lost,
        // because App and UI wasn't completely initialized
        // workaround: QShareActivity remembers that an Intent is pending
        if(!mPendingIntentsChecked) {
            mPendingIntentsChecked = true;
            mShareUtils->checkPendingIntents(mAppDataFilesPath);
        }
    }
}
// we don't need permissions if we only share files to other apps using FileProvider
// but we need permissions if other apps share their files with out app and we must access those files
bool ApplicationUI::checkPermission() {
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    if(r == QtAndroid::PermissionResult::Denied) {
        QtAndroid::requestPermissionsSync( QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE" );
        r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if(r == QtAndroid::PermissionResult::Denied) {
            qDebug() << "Permission denied";
            emit noDocumentsWorkLocation();
            return false;
        }
   }
    qDebug() << "YEP: Permission OK";
   return true;
}
#endif

#if defined(Q_OS_ANDROID)

// to get access to all files you need a special permission
// add <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/> to your Manifest
// then ask user to get full access
// HINT: if you want to deploy your app via Play Store, you have to ask Google to use this permission
// per ex. an app like a FileManager could be valid
// if your business app is running inside a MDM, you don't need to ask Google
// ATTENTION: don't forget to set your package name !
// see https://forum.qt.io/topic/137019/cannot-grant-manage_external_storage-permission-on-android-11/2
// see https://bugreports.qt.io/browse/QTBUG-98974?focusedCommentId=680551&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-680551
void ApplicationUI::accessAllFiles()
{
   // QOperatingSystemVersion("Android", 13.0.0)
   // QOperatingSystemVersion("macOS", 12.5.0)
   qDebug() << "current QOperatingSystemVersion:" << QOperatingSystemVersion::current();
   if(QOperatingSystemVersion::current() >= QOperatingSystemVersion(QOperatingSystemVersion::Android, 13)) {
        qDebug() << "it is Android 13 or greater !";
   }
   if(QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 11)) {
        qDebug() << "it is less then Android 11 - ALL FILES permission isn't possible!";
        return;
   }

// Here you have to set your PackageName
#define PACKAGE_NAME "package:org.ekkescorner.examples.sharex"
   jboolean value = QAndroidJniObject::callStaticMethod<jboolean>("android/os/Environment", "isExternalStorageManager");
   if(value == false) {
        qDebug() << "requesting ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION";
        QAndroidJniObject ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION = QAndroidJniObject::getStaticObjectField( "android/provider/Settings", "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION","Ljava/lang/String;" );
        QAndroidJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION.object());
        QAndroidJniObject jniPath = QAndroidJniObject::fromString(PACKAGE_NAME);
        QAndroidJniObject jniUri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
        QAndroidJniObject jniResult = intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", jniUri.object<jobject>() );
        QtAndroid::startActivity(intent, 0);
   } else {
        qDebug() << "SUCCESS ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION";
   }
}
#endif

