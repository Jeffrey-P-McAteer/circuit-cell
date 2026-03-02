#pragma once

#include <QMainWindow>
#include <QQuickWidget>
#include <Qt3DExtras/Qt3DWindow>
#include <Qt3DCore/QEntity>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

public slots: // slots is a magic QML thing
    void someCppSlot();

private:
    Qt3DExtras::Qt3DWindow *view3D;
    QWidget *container;
    QQuickWidget *overlayWidget;
    Qt3DCore::QEntity *rootEntity;
};


