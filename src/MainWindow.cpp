
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
    // // ----- 3D Scene -----
    // view3D = new Qt3DExtras::Qt3DWindow();
    // view3D->defaultFrameGraph()->setClearColor(Qt::white);

    // rootEntity = new Qt3DCore::QEntity();

    // // Example 3D sphere
    // auto *sphereEntity = new Qt3DCore::QEntity(rootEntity);
    // auto *sphereMesh = new Qt3DExtras::QSphereMesh();
    // sphereMesh->setRadius(1.0f);
    // sphereEntity->addComponent(sphereMesh);

    // auto *material = new Qt3DExtras::QPhongMaterial(rootEntity);
    // sphereEntity->addComponent(material);

    // auto *transform = new Qt3DCore::QTransform();
    // sphereEntity->addComponent(transform);

    // view3D->setRootEntity(rootEntity);

    // // Camera
    // auto *camera = view3D->camera();
    // camera->lens()->setPerspectiveProjection(45.0f, 16.0f/9.0f, 0.1f, 1000.0f);
    // camera->setPosition(QVector3D(0, 0, 10));
    // camera->setViewCenter(QVector3D(0,0,0));

    // auto *camController = new Qt3DExtras::QOrbitCameraController(rootEntity);
    // camController->setCamera(camera);

    // // ----- Embed 3D into QWidget -----
    // container = QWidget::createWindowContainer(view3D);
    // setCentralWidget(container);

    // // ----- QML Overlay -----
    // overlayWidget = new QQuickWidget();
    // overlayWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    // overlayWidget->rootContext()->setContextProperty("mainWindow", this); // expose C++ object
    // overlayWidget->setSource(QUrl("qrc:/OverlayUI.qml"));

    // // Overlay layout
    // auto *layout = new QVBoxLayout(container);
    // layout->setContentsMargins(0,0,0,0);
    // layout->addWidget(overlayWidget);
    // overlayWidget->setAttribute(Qt::WA_TransparentForMouseEvents, false);
    // overlayWidget->setClearColor(Qt::transparent);

    view3D = new Qt3DExtras::Qt3DWindow();
    view3D->defaultFrameGraph()->setClearColor(Qt::white);

    rootEntity = new Qt3DCore::QEntity();

    // Example 3D sphere
    auto *sphereEntity = new Qt3DCore::QEntity(rootEntity);
    auto *sphereMesh = new Qt3DExtras::QSphereMesh();
    sphereMesh->setRadius(1.0f);
    sphereEntity->addComponent(sphereMesh);

    auto *material = new Qt3DExtras::QPhongMaterial(rootEntity);
    sphereEntity->addComponent(material);

    auto *transform = new Qt3DCore::QTransform();
    sphereEntity->addComponent(transform);

    view3D->setRootEntity(rootEntity);

    // Camera
    auto *camera = view3D->camera();
    camera->lens()->setPerspectiveProjection(45.0f, 16.0f/9.0f, 0.1f, 1000.0f);
    camera->setPosition(QVector3D(0, 0, 10));
    camera->setViewCenter(QVector3D(0,0,0));

    auto *camController = new Qt3DExtras::QOrbitCameraController(rootEntity);
    camController->setCamera(camera);

    // ----- Embed 3D into QWidget -----
    container = QWidget::createWindowContainer(view3D);
    setCentralWidget(container);

    // ----- Embed 3D -----
    container = QWidget::createWindowContainer(view3D);

    QWidget *central = new QWidget(this);
    setCentralWidget(central);

    // ----- QML Overlay -----
    overlayWidget = new QQuickWidget(central);
    overlayWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    overlayWidget->rootContext()->setContextProperty("mainWindow", this);
    overlayWidget->setSource(QUrl("qrc:/OverlayUI.qml"));

    // Important:
    overlayWidget->setClearColor(Qt::transparent);
    overlayWidget->setAttribute(Qt::WA_TranslucentBackground);
    overlayWidget->setStyleSheet("background: transparent");

    // ----- Stack them manually -----
    container->setParent(central);
    overlayWidget->setParent(central);

    // Make them same size
    container->setGeometry(rect());
    overlayWidget->setGeometry(rect());

    // Ensure QML is above
    overlayWidget->raise();
}


MainWindow::~MainWindow() {}

void MainWindow::someCppSlot() {
    //std::cout << "someCppSlot() is running!" << std::endl;
    qDebug() << "Button clicked from QML!";
}
