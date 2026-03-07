#include "MainWindow.hpp"

// cmake-generated
#include "version.h"

#include <iostream>

#include <QApplication>

int main(int argc, char *argv[])
{
    std::cout << APP_VERSION_STRING << std::endl;

    QApplication app(argc, argv);

    QApplication::setApplicationName("circuit-cell");
    QApplication::setOrganizationName("ExampleOrg");

    // This is what sway should use to make the window float, if the user wants that (app_id=circuit-cell)
    QGuiApplication::setDesktopFileName("circuit-cell");

    MainWindow window;
    window.resize(1024, 768);
    window.setWindowState(Qt::WindowFullScreen);
    window.setWindowFlags(Qt::Window | Qt::FramelessWindowHint);
    window.show();

    return app.exec();
}
