// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#ifndef ANDROIDSHAREUTILS_H
#define ANDROIDSHAREUTILS_H

#include <QtAndroid>
#include <QAndroidActivityResultReceiver>

#include "cpp/shareutils.hpp"

class AndroidShareUtils : public PlatformShareUtils, public QAndroidActivityResultReceiver
{
public:
    AndroidShareUtils(QObject* parent = 0);
    void share(const QString &text, const QUrl &url) override;
    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;
    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;
    void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) override;

    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);

};


#endif // ANDROIDSHAREUTILS_H
