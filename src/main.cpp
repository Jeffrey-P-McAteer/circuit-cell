#include "MainWindow.hpp"

// cmake-generated
#include "version.h"

#include <iostream>

#include <QApplication>
#include <QIcon>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCursor>
#include <QSurfaceFormat>

int main(int argc, char *argv[])
{
    std::cout << "APP_VERSION_STRING = " << APP_VERSION_STRING << std::endl;
    std::cout << "QGuiApplication::platformName() = " << QGuiApplication::platformName().toStdString() << std::endl;

    QSurfaceFormat fmt;
    fmt.setDepthBufferSize(24);
    fmt.setSamples(4);            // matches multisample: true in QML
    fmt.setStencilBufferSize(8);
    QSurfaceFormat::setDefaultFormat(fmt);

    QApplication app(argc, argv);

    QApplication::setApplicationName("circuit-cell");
    QApplication::setOrganizationName("ExampleOrg");

    // This is what sway should use to make the window float, if the user wants that (app_id=circuit-cell)
    QGuiApplication::setDesktopFileName("circuit-cell");

    app.setWindowIcon(QIcon("qrc:/icons/icon-128.png"));

    MainWindow window;
    window.resize(1024, 768);
    window.setWindowState(Qt::WindowFullScreen);
    window.setWindowFlags(Qt::Window | Qt::FramelessWindowHint);
    window.show();

    return app.exec();
}
