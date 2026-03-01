
#include "MainWindow.hpp"

#include <iostream>

#include <QQmlContext>
#include <QVBoxLayout>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    // Central widget (could be your existing OpenGL or QWidget canvas)
    QWidget* central = new QWidget(this);
    this->setCentralWidget(central);

    QVBoxLayout* layout = new QVBoxLayout(central);
    layout->setContentsMargins(0, 0, 0, 0);

    // Existing C++ widgets can go here
    // layout->addWidget(someExistingWidget);

    // QML overlay
    overlayWidget = new QQuickWidget(this);
    overlayWidget->setSource(QUrl(QStringLiteral("qrc:/OverlayUI.qml")));
    overlayWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    overlayWidget->setClearColor(Qt::transparent);
    overlayWidget->setAttribute(Qt::WA_TranslucentBackground);
    overlayWidget->setFocusPolicy(Qt::NoFocus);

    // Expose MainWindow to QML for signals/slots if needed
    overlayWidget->rootContext()->setContextProperty("mainWindow", this);

    layout->addWidget(overlayWidget);
}

MainWindow::~MainWindow() {}

void MainWindow::someCppSlot() {
    std::cout << "someCppSlot() is running!" << std::endl;

}
