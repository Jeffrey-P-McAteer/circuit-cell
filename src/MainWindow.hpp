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

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void spawnEnemy();
    Q_INVOKABLE void quitGame();

public slots: // slots is a magic QML thing
    void someCppSlot();
    void resizeEvent(QResizeEvent *event);

private:
    // Qt3DExtras::Qt3DWindow *view3D;
    // QWidget *container;
    // QQuickWidget *overlayWidget;
    // Qt3DCore::QEntity *rootEntity;
};


