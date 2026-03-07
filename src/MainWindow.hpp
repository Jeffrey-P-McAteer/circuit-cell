#pragma once

#include <QMainWindow>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void spawnEnemy();
    Q_INVOKABLE void quitGame();
};


