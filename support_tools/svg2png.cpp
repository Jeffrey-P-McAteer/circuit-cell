#include <QGuiApplication>
#include <QImage>
#include <QPainter>
#include <QSvgRenderer>
#include <QString>
#include <iostream>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    if (argc != 5) {
        std::cerr << "Usage: svg2png <input.svg> <output.png> <width> <height>\n";
        return 1;
    }

    QString input = argv[1];
    QString output = argv[2];

    int width = std::stoi(argv[3]);
    int height = std::stoi(argv[4]);

    QSvgRenderer renderer(input);

    if (!renderer.isValid()) {
        std::cerr << "Failed to load SVG\n";
        return 2;
    }

    QImage img(width, height, QImage::Format_ARGB32);
    img.fill(Qt::transparent);

    QPainter painter(&img);
    renderer.render(&painter, QRectF(0, 0, width, height));
    painter.end();

    if (!img.save(output)) {
        std::cerr << "Failed to save PNG\n";
        return 3;
    }

    return 0;
}
