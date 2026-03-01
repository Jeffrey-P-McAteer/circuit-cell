#pragma once

#include <QMainWindow>
#include <QQuickWidget>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

private:
    QQuickWidget* overlayWidget;
};


