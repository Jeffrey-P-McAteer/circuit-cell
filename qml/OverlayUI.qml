import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    anchors.fill: parent

    Rectangle {
        id: panel
        width: 200
        height: 100
        color: "#80000000"   // semi-transparent background
        anchors.top: parent.top
        anchors.right: parent.right
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 10

            Button {
                text: "Click Me"
                onClicked: mainWindow.someCppSlot()  // calls C++ function
            }

            Label {
                text: "Overlay Label"
            }
        }
    }
}


