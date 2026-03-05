
#include "MainWindow.hpp"

#include <iostream>

#include <Qt3DExtras/QOrbitCameraController>
#include <Qt3DExtras/QPhongMaterial>
#include <Qt3DExtras/QSphereMesh>
#include <Qt3DExtras/QForwardRenderer>
#include <Qt3DRender/QCamera>
#include <Qt3DCore/QTransform>
#include <QQmlContext>
#include <QVBoxLayout>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    QQuickWidget *view = new QQuickWidget(this);

    view->setResizeMode(QQuickWidget::SizeRootObjectToView);

    view->rootContext()->setContextProperty("mainWindow", this);

    view->setSource(QUrl("qrc:/MainUI.qml"));

    setCentralWidget(view);
}


MainWindow::~MainWindow() {}

void MainWindow::resizeEvent(QResizeEvent *event)
{
    QMainWindow::resizeEvent(event);

    // if (container)
    //     container->setGeometry(rect());

    // if (overlayWidget)
    //     overlayWidget->setGeometry(rect());
}

void MainWindow::startGame()
{
    qDebug() << "Start game pressed";
}

void MainWindow::spawnEnemy()
{
    qDebug() << "Spawn enemy pressed";
}

void MainWindow::quitGame()
{
    qApp->quit();
}

void MainWindow::someCppSlot() {
    //std::cout << "someCppSlot() is running!" << std::endl;
    qDebug() << "Button clicked from QML!";
}
