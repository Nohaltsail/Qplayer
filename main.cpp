#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/MusicInfo.h"
#include "backend/PlayerController.h"

using namespace Qt::StringLiterals;

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    QString iconPath = QDir::current().absoluteFilePath("icons/app_icon.ico");
    if (QFileInfo::exists(iconPath)) {
        app.setWindowIcon(QIcon(iconPath));
        qDebug() << "Application icon loaded from:" << iconPath;
    } else {
        qDebug() << "Icon file not found:" << iconPath;
    }

    qmlRegisterType<PlayerController>("QPlayer", 1, 0, "PlayerController");
    qRegisterMetaType<MusicInfo>();
    qmlRegisterUncreatableMetaObject(MusicInfo::staticMetaObject, "QPlayer", 1, 0, "SongInfo", "Not creatable in QML");

    QQmlApplicationEngine engine;

    PlayerController* playerController = new PlayerController();
    engine.rootContext()->setContextProperty("playerController", playerController);

    const QUrl url(u"qrc:/QPlayer/Main.qml"_s);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::destroyed, playerController, &QObject::deleteLater);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        delete playerController;
        return -1;
    }

    return app.exec();
}