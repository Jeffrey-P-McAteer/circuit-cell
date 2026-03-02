import QtQuick 6.6
import QtQuick.Controls 6.6

Rectangle {
    width: 800
    height: 600
    color: "transparent"

    Button {
        text: "Click Me"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        onClicked: mainWindow.someCppSlot()
    }

    Text {
        text: "Overlay on top of 3D!"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 60
        font.pixelSize: 24
        color: "black"
    }
}
