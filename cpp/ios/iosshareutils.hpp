// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#ifndef __IOSSHAREUTILS_H__
#define __IOSSHAREUTILS_H__

#include "shareutils.hpp"

class IosShareUtils : public PlatformShareUtils
{
    Q_OBJECT

public:
    explicit IosShareUtils(QObject *parent = 0);
    Q_INVOKABLE void share(const QString &text, const QUrl &url);
    Q_INVOKABLE void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
    Q_INVOKABLE void editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);

    void handleDocumentPreviewDone();

private:
    int mCurrentRequestId;
};

#endif
