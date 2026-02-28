#include <iostream>

#include <QApplication>

#include "MainWindow.hpp"

// cmake-generated
#include "version.h"

int main(int argc, char *argv[])
{
    std::cout << APP_VERSION_STRING << std::endl;

    QApplication app(argc, argv);

    QApplication::setApplicationName("circuit-cell");
    QApplication::setOrganizationName("ExampleOrg");

    MainWindow window;
    window.resize(1024, 768);
    window.show();

    return app.exec();
}
