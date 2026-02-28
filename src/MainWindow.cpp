#include "MainWindow.hpp"

#include <QWidget>
#include <QVBoxLayout>

#include <Qt3DExtras/Qt3DWindow>
#include <Qt3DExtras/QTorusMesh>
#include <Qt3DExtras/QPhongMaterial>
#include <Qt3DExtras/QOrbitCameraController>

#include <Qt3DCore/QEntity>
#include <Qt3DCore/QTransform>

#include <Qt3DRender/QCamera>
#include <Qt3DRender/QPointLight>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    // --- Create 3D Window ---
    Qt3DExtras::Qt3DWindow *view = new Qt3DExtras::Qt3DWindow();
    QWidget *container = QWidget::createWindowContainer(view);

    // Optional: smoother rendering
    container->setMinimumSize(QSize(400, 300));
    container->setFocusPolicy(Qt::StrongFocus);

    setCentralWidget(container);

    // --- Root Entity ---
    Qt3DCore::QEntity *rootEntity = new Qt3DCore::QEntity();

    // --- Torus Entity ---
    Qt3DCore::QEntity *torusEntity = new Qt3DCore::QEntity(rootEntity);

    auto *torusMesh = new Qt3DExtras::QTorusMesh();
    torusMesh->setRadius(2.0f);
    torusMesh->setMinorRadius(0.5f);
    torusMesh->setRings(100);
    torusMesh->setSlices(20);

    auto *material = new Qt3DExtras::QPhongMaterial();
    material->setDiffuse(QColor(100, 180, 255));

    auto *transform = new Qt3DCore::QTransform();
    transform->setScale(1.5f);

    torusEntity->addComponent(torusMesh);
    torusEntity->addComponent(material);
    torusEntity->addComponent(transform);

    // --- Light ---
    Qt3DCore::QEntity *lightEntity = new Qt3DCore::QEntity(rootEntity);
    auto *light = new Qt3DRender::QPointLight(lightEntity);
    light->setColor(Qt::white);
    light->setIntensity(1);

    auto *lightTransform = new Qt3DCore::QTransform(lightEntity);
    lightTransform->setTranslation(QVector3D(0, 10, 10));

    lightEntity->addComponent(light);
    lightEntity->addComponent(lightTransform);

    // --- Camera ---
    Qt3DRender::QCamera *camera = view->camera();
    camera->lens()->setPerspectiveProjection(
        45.0f, 16.0f/9.0f, 0.1f, 1000.0f);
    camera->setPosition(QVector3D(0, 0, 20.0f));
    camera->setViewCenter(QVector3D(0, 0, 0));

    // --- Camera Controller (mouse orbit) ---
    auto *camController = new Qt3DExtras::QOrbitCameraController(rootEntity);
    camController->setLinearSpeed(50.0f);
    camController->setLookSpeed(180.0f);
    camController->setCamera(camera);

    view->setRootEntity(rootEntity);
}


