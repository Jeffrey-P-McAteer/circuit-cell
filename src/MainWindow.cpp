#include "MainWindow.hpp"
#include <QQuickWidget>
#include <QQmlContext>
#include <QCoreApplication>
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
