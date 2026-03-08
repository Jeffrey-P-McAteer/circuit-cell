#include "MainWindow.hpp"
#include <QQuickWidget>
#include <QQmlContext>
#include <QDebug>
#include <QCoreApplication>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    QQuickWidget *view = new QQuickWidget(this);

    view->setResizeMode(QQuickWidget::SizeRootObjectToView);

    view->rootContext()->setContextProperty("mainWindow", this);

    view->setSource(QUrl("qrc:/MainUI.qml"));

    // Make the QML fill the widget, not just sit at its natural size
    view->setResizeMode(QQuickWidget::SizeRootObjectToView);

    view->setFocusPolicy(Qt::StrongFocus);
    view->installEventFilter(this);  // optional, for custom key routing

    view->setClearColor(QColor("#1a1a2e")); // tells the OpenGL surface what colour to clear to between frames
    view->setAttribute(Qt::WA_OpaquePaintEvent); // attribute prevents Qt from drawing the default grey widget background behind it, which would cause a flash on resize

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
    QCoreApplication::quit();
}
