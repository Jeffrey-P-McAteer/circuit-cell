#pragma once

#include <QMainWindow>
#include <QQuickWidget>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

public slots: // slots is a magic QML thing
    void someCppSlot();

private:
    QQuickWidget* overlayWidget;
};


