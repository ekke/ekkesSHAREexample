// (c) 2017 Ekkehard Gentz (ekke)
// this project is based on ideas from
// http://blog.lasconic.com/share-on-ios-and-android-using-qml/
// see github project https://github.com/lasconic/ShareUtils-QML
// also inspired by:
// https://www.androidcode.ninja/android-share-intent-example/
// https://www.calligra.org/blogs/sharing-with-qt-on-android/
// https://stackoverflow.com/questions/7156932/open-file-in-another-app
// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
// see also /COPYRIGHT and /LICENSE

// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#ifndef SHAREUTILS_H
#define SHAREUTILS_H

#include <QObject>

#include <QDebug>

class PlatformShareUtils : public QObject
{
    Q_OBJECT
signals:
    void shareEditDone(int requestCode);
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);

public:
    PlatformShareUtils(QObject *parent = 0) : QObject(parent){}
    virtual ~PlatformShareUtils() {}
    virtual void share(const QString &text, const QUrl &url){ qDebug() << text << url; }
    virtual void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId){
        qDebug() << filePath << " - " << title << "requestId " << requestId << " - " << mimeType; }
    virtual void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId){
        qDebug() << filePath << " - " << title << " requestId: " << requestId << " - " << mimeType; }
    virtual void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId){
        qDebug() << filePath << " - " << title << " requestId: " << requestId << " - " << mimeType; }
};

class ShareUtils : public QObject
{
    Q_OBJECT


signals:
    void shareEditDone(int requestCode);
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);

public slots:
    void onShareEditDone(int requestCode);
    void onShareFinished(int requestCode);
    void onShareNoAppAvailable(int requestCode);
    void onShareError(int requestCode, QString message);

public:
    explicit ShareUtils(QObject *parent = 0);
    Q_INVOKABLE void share(const QString &text, const QUrl &url);
    Q_INVOKABLE void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);

private:
    PlatformShareUtils* mPlatformShareUtils;

};

#endif //SHAREUTILS_H
