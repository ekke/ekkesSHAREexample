// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>

#include <QQuickStyle>

#include "applicationui.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickStyle::setStyle("Material");
    QGuiApplication app(argc, argv);

    app.setOrganizationName("ekkes-corner");
    app.setOrganizationDomain("org.ekkescorner.share.example");

    ApplicationUI appui;

    QQmlApplicationEngine engine;

    // from QML we have access to ApplicationUI as myApp
    QQmlContext* context = engine.rootContext();
    context->setContextProperty("myApp", &appui);
    // some more context properties
    appui.addContextProperty(context);

#if defined(Q_OS_ANDROID)
    QObject::connect(&app, &QGuiApplication::applicationStateChanged, &appui, &ApplicationUI::onApplicationStateChanged );
#endif
    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
