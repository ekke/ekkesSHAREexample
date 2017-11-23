// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include "androidshareutils.hpp"

#include <QUrl>

#include <QtAndroidExtras/QAndroidJniObject>

const static int RESULT_OK = -1;
const static int RESULT_CANCELED = 0;


AndroidShareUtils::AndroidShareUtils(QObject* parent) : PlatformShareUtils(parent)
{
    //
}

void AndroidShareUtils::share(const QString &text, const QUrl &url)
{
    QAndroidJniObject jsText = QAndroidJniObject::fromString(text);
    QAndroidJniObject jsUrl = QAndroidJniObject::fromString(url.toString());
    QAndroidJniObject::callStaticMethod<void>("org/ekkescorner/utils/QShareUtils",
                                              "share",
                                              "(Ljava/lang/String;Ljava/lang/String;)V",
                                              jsText.object<jstring>(), jsUrl.object<jstring>());
}

/*
 * Without a requestId we're going the Java - way with one simple JNI call
 * Getting a requestId we need the result to know if user canceled or finished sending the file
*/
void AndroidShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    if(requestId <= 0) {
        QAndroidJniObject jsPath = QAndroidJniObject::fromString(filePath);
        QAndroidJniObject jsTitle = QAndroidJniObject::fromString(title);
        QAndroidJniObject jsMimeType = QAndroidJniObject::fromString(mimeType);
        QAndroidJniObject::callStaticMethod<void>("org/ekkescorner/utils/QShareUtils",
                                                  "sendFile",
                                                  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                  jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>());
        return;
    }
    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to send a file from APP DATA will fail
    QAndroidJniObject jniPath = QAndroidJniObject::fromString("file://"+filePath);
    if(!jniPath.isValid()) {
        qWarning() << "QAndroidJniObject jniPath not valid.";
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QAndroidJniObject jniUri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if(!jniUri.isValid()) {
        qWarning() << "QAndroidJniObject jniUri not valid.";
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QAndroidJniObject jniAction = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_SEND");
    if(!jniAction.isValid()) {
        qWarning() << "QAndroidJniObject jniParam not valid.";
        return;
    }
    // then create the Intent Object for this Action
    QAndroidJniObject jniIntent("android/content/Intent","(Ljava/lang/String;)V",jniAction.object<jstring>());
    if(!jniIntent.isValid()) {
        qWarning() << "QAndroidJniObject jniIntent not valid.";
        return;
    }

    // THE MIME TYPE
    // create a Java String for the File Type (Mime Type)
    QAndroidJniObject jniMimeType = QAndroidJniObject::fromString(mimeType);
    if(!jniMimeType.isValid()) {
        qWarning() << "QAndroidJniObject jniMimeType not valid.";
        return;
    }
    // set Type (MimeType)
    QAndroidJniObject jniType = jniIntent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", jniMimeType.object<jstring>());
    if(!jniType.isValid()) {
        qWarning() << "QAndroidJniObject jniType not valid.";
        return;
    }

    // THE EXTRA STREAM
    // create a Java String for the EXTRA
    QAndroidJniObject jniExtra = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent", "EXTRA_STREAM");
    if(!jniExtra.isValid()) {
        qWarning() << "QAndroidJniObject jniExtra not valid.";
        return;
    }
    // put Extra (EXTRA_STREAM and URI)
    QAndroidJniObject jniExtraStreamUri = jniIntent.callObjectMethod("putExtra", "(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;", jniExtra.object<jstring>(), jniUri.object<jobject>());
    // QAndroidJniObject jniExtraStreamUri = jniIntent.callObjectMethod("putExtra", "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;", jniExtra.object<jstring>(), jniExtra.object<jstring>());
    if(!jniExtraStreamUri.isValid()) {
        qWarning() << "QAndroidJniObject jniExtraStreamUri not valid.";
        return;
    }

    // now all is ready to start the Activity:
    // we have the JNI Object, know the requestId
    // and want the Result back into 'this' handleActivityResult(...)
    QtAndroid::startActivity(jniIntent, requestId, this);
}

/*
 * Without a requestId we're going the Java - way with one simple JNI call
 * Getting a requestId we need the result to know if user canceled or finished viewing the file
*/
void AndroidShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    if(requestId <= 0) {
        QAndroidJniObject jsPath = QAndroidJniObject::fromString(filePath);
        QAndroidJniObject jsTitle = QAndroidJniObject::fromString(title);
        QAndroidJniObject jsMimeType = QAndroidJniObject::fromString(mimeType);
        QAndroidJniObject::callStaticMethod<void>("org/ekkescorner/utils/QShareUtils",
                                                  "viewFile",
                                                  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                  jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>());
        return;
    }

    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to view or edit a file from APP DATA will fail
    QAndroidJniObject jniPath = QAndroidJniObject::fromString("file://"+filePath);
    if(!jniPath.isValid()) {
        qWarning() << "QAndroidJniObject jniPath not valid.";
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QAndroidJniObject jniUri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if(!jniUri.isValid()) {
        qWarning() << "QAndroidJniObject jniUri not valid.";
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QAndroidJniObject jniParam = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_VIEW");
    if(!jniParam.isValid()) {
        qWarning() << "QAndroidJniObject jniParam not valid.";
        return;
    }
    // then create the Intent Object for this Action
    QAndroidJniObject jniIntent("android/content/Intent","(Ljava/lang/String;)V",jniParam.object<jstring>());
    if(!jniIntent.isValid()) {
        qWarning() << "QAndroidJniObject jniIntent not valid.";
        return;
    }

    // THE FILE TYPE
    // create a Java String for the File Type (Mime Type)
    QAndroidJniObject jniType = QAndroidJniObject::fromString(mimeType);
    if(!jniType.isValid()) {
        qWarning() << "QAndroidJniObject jniType not valid.";
        return;
    }
    // set Data (the URI) and Type (MimeType)
    QAndroidJniObject jniResult = jniIntent.callObjectMethod("setDataAndType", "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;", jniUri.object<jobject>(), jniType.object<jstring>());
    if(!jniResult.isValid()) {
        qWarning() << "QAndroidJniObject jniResult not valid.";
        return;
    }

    // now all is ready to start the Activity:
    // we have the JNI Object, know the requestId
    // and want the Result back into 'this' handleActivityResult(...)
    QtAndroid::startActivity(jniIntent, requestId, this);
}

/*
 * Without a requestId we're going the Java - way with one simple JNI call
 * Getting a requestId we need the result to know if user canceled or saved the edited file
*/
void AndroidShareUtils::editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
    if(requestId <= 0) {
        QAndroidJniObject jsPath = QAndroidJniObject::fromString(filePath);
        QAndroidJniObject jsTitle = QAndroidJniObject::fromString(title);
        QAndroidJniObject jsMimeType = QAndroidJniObject::fromString(mimeType);
        QAndroidJniObject::callStaticMethod<void>("org/ekkescorner/utils/QShareUtils",
                                                  "editFile",
                                                  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                  jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>());
        return;
    }

    // THE FILE PATH
    // to get a valid Path we must prefix file://
    // attention file must be inside Users Documents folder !
    // trying to view or edit a file from APP DATA will fail
    QAndroidJniObject jniPath = QAndroidJniObject::fromString("file://"+filePath);
    if(!jniPath.isValid()) {
        qWarning() << "QAndroidJniObject jniPath not valid.";
        return;
    }
    // next step: convert filePath Java String into Java Uri
    QAndroidJniObject jniUri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jniPath.object<jstring>());
    if(!jniUri.isValid()) {
        qWarning() << "QAndroidJniObject jniUri not valid.";
        return;
    }

    // THE INTENT ACTION
    // create a Java String for the ACTION
    QAndroidJniObject jniParam = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent", "ACTION_EDIT");
    if(!jniParam.isValid()) {
        qWarning() << "QAndroidJniObject jniParam not valid.";
        return;
    }
    // then create the Intent Object for this Action
    QAndroidJniObject jniIntent("android/content/Intent","(Ljava/lang/String;)V",jniParam.object<jstring>());
    if(!jniIntent.isValid()) {
        qWarning() << "QAndroidJniObject jniIntent not valid.";
        return;
    }

    // THE FILE TYPE
    // create a Java String for the File Type (Mime Type)
    QAndroidJniObject jniType = QAndroidJniObject::fromString(mimeType);
    if(!jniType.isValid()) {
        qWarning() << "QAndroidJniObject jniType not valid.";
        return;
    }
    // set Data (the URI) and Type (MimeType)
    QAndroidJniObject jniResult = jniIntent.callObjectMethod("setDataAndType", "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;", jniUri.object<jobject>(), jniType.object<jstring>());
    if(!jniResult.isValid()) {
        qWarning() << "QAndroidJniObject jniResult not valid.";
        return;
    }

    // now all is ready to start the Activity:
    // we have the JNI Object, know the requestId
    // and want the Result back into 'this' handleActivityResult(...)
    QtAndroid::startActivity(jniIntent, requestId, this);
}

void AndroidShareUtils::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    Q_UNUSED(data);
    qDebug() << "handleActivityResult: " << receiverRequestCode << "ResultCode:" << resultCode;
    // we're getting RESULT_OK only if edit is done
    if(resultCode == RESULT_OK) {
        emit shareEditDone(receiverRequestCode);
    } else if(resultCode == RESULT_CANCELED) {
        emit shareFinished(receiverRequestCode);
    } else {
        qDebug() << "wrong result code: " << resultCode << " from request: " << receiverRequestCode;
    }
}
