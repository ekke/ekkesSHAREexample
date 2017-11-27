// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#ifndef APPLICATIONUI_HPP
#define APPLICATIONUI_HPP

#include <QObject>

#include <QtQml>
#include "cpp/shareutils.hpp"

class ApplicationUI : public QObject
{
    Q_OBJECT

public:
     ApplicationUI(QObject *parent = 0);

     void addContextProperty(QQmlContext* context);

     Q_INVOKABLE
     void copyAssetsToAPPData();

     Q_INVOKABLE
     QString filePathDocumentsLocation(const int requestId);

     Q_INVOKABLE
     bool deleteFromDocumentsLocation(const int requestId);

     Q_INVOKABLE
     bool updateFileFromDocumentsLocation(const int requestId);

     // only used on Android and when not dealing with QAndroidActivityResultReceiver
     Q_INVOKABLE
     void setShareState(const bool isShareActive, const bool isEditActive, const int requestCode);

signals:

public slots:
#if defined(Q_OS_ANDROID)
     void onApplicationStateChanged(Qt::ApplicationState applicationState);
#endif

private:
     ShareUtils* mShareUtils;

     QString mAppDataFilesPath;
     QString mDocumentsWorkPath;

     // only used on Android and when not dealing with QAndroidActivityResultReceiver
     bool mShareActive;
     bool mShareEditActive;
     int mShareRequestCode;

     bool copyAssetFile(const QString sourceFilePath, const QString destinationFilePath);
};

#endif // APPLICATIONUI_HPP
