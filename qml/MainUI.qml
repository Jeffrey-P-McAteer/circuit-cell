import QtQuick
import QtQuick.Controls
import QtQuick3D

Item {

    width: 1280
    height: 720

    /*
        ==========================
        3D GAME WORLD
        ==========================
    */

    View3D {
        id: worldView
        anchors.fill: parent

        camera: mainCamera

        environment: SceneEnvironment {
            clearColor: "#202020"
            backgroundMode: SceneEnvironment.Color
        }

        Node {
            id: sceneRoot

            /*
                CAMERA
            */

            PerspectiveCamera {
                id: mainCamera
                position: Qt.vector3d(0, 5, 12)
                eulerRotation.x: -20
            }

            /*
                LIGHTING
            */

            DirectionalLight {
                eulerRotation.x: -45
                eulerRotation.y: 30
                brightness: 1.2
            }

            /*
                SIMPLE TEST MODEL
            */

            Model {
                source: "#Cube"
                scale: Qt.vector3d(2,2,2)

                materials: DefaultMaterial {
                    diffuseColor: "lightblue"
                }
            }

            /*
                FLOOR
            */

            Model {
                source: "#Rectangle"
                scale: Qt.vector3d(20,1,20)
                y: -2

                materials: DefaultMaterial {
                    diffuseColor: "#606060"
                }
            }
        }
    }

    /*
        ==========================
        HUD OVERLAY
        ==========================
    */

    Item {
        id: hud
        anchors.fill: parent

        Text {
            text: "Qt Game Prototype"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            font.pixelSize: 32
            color: "white"
        }

        Column {

            spacing: 10

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20

            Button {
                text: "Start Game"

                onClicked: {
                    mainWindow.startGame()
                }
            }

            Button {
                text: "Spawn Enemy"

                onClicked: {
                    mainWindow.spawnEnemy()
                }
            }

            Button {
                text: "Quit"

                onClicked: {
                    mainWindow.quitGame()
                }
            }
        }

        /*
            Example status text
        */

        Text {
            text: "Health: 100"
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 20
            color: "white"
            font.pixelSize: 22
        }
    }
}
