import QtQuick
import QtQuick.Controls
import QtQuick3D

Item {

    width: 1280
    height: 720
    focus: true

    // Movement speed
    property real moveSpeed: 0.2

    // Camera rotation properties
    property real cameraYaw: 0
    property real cameraPitch: -20
    property real cameraDistance: 12
    property real cameraHeight: 5

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
            clearColor: "#202060"
            backgroundMode: SceneEnvironment.Color
        }

        Node {
            id: sceneRoot

            /*
                CAMERA
            */

            PerspectiveCamera {
                id: mainCamera
                position: Qt.vector3d(
                    playerCube.x + cameraDistance * Math.cos(cameraYaw * Math.PI / 180) * Math.cos(cameraPitch * Math.PI / 180),
                    playerCube.y + cameraHeight + cameraDistance * Math.sin(cameraPitch * Math.PI / 180),
                    playerCube.z + cameraDistance * Math.sin(cameraYaw * Math.PI / 180) * Math.cos(cameraPitch * Math.PI / 180)
                )
                eulerRotation.x: cameraPitch
                eulerRotation.y: cameraYaw
            }

            /*
                LIGHTING
            */

            DirectionalLight {
                brightness: 5
                eulerRotation.x: -45
                eulerRotation.y: 45
            }

            /*
                PLAYER CUBE (controllable)
            */

            Model {
                id: playerCube
                source: "#Cube"
                scale: Qt.vector3d(2,2,2)
                y: 1

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
                y: -1

                materials: DefaultMaterial {
                    diffuseColor: "#606060"
                }
            }
        }

        // Mouse area for camera rotation
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property real lastX: 0
            property real lastY: 0
            property bool isDragging: false

            onPressed: function(mouse) {
                lastX = mouse.x
                lastY = mouse.y
                isDragging = true
                worldView.forceActiveFocus()
            }

            onReleased: {
                isDragging = false
            }

            onPositionChanged: function(mouse) {
                if (isDragging) {
                    var deltaX = mouse.x - lastX
                    var deltaY = mouse.y - lastY

                    cameraYaw += deltaX * 0.3
                    cameraPitch -= deltaY * 0.3

                    // Clamp pitch to avoid gimbal lock
                    cameraPitch = Math.max(-89, Math.min(89, cameraPitch))

                    lastX = mouse.x
                    lastY = mouse.y
                }
            }

            onWheel: function(wheel) {
                cameraDistance -= wheel.angleDelta.y * 0.01
                cameraDistance = Math.max(5, Math.min(30, cameraDistance))
            }
        }
    }

    // Keyboard controls
    Keys.onPressed: function(event) {
        var moveX = 0
        var moveZ = 0

        // Calculate forward/right vectors based on camera yaw
        var forwardX = Math.cos(cameraYaw * Math.PI / 180)
        var forwardZ = Math.sin(cameraYaw * Math.PI / 180)
        var rightX = Math.cos((cameraYaw + 90) * Math.PI / 180)
        var rightZ = Math.sin((cameraYaw + 90) * Math.PI / 180)

        if (event.key === Qt.Key_W) {
            moveX += forwardX * moveSpeed
            moveZ += forwardZ * moveSpeed
        }
        if (event.key === Qt.Key_S) {
            moveX -= forwardX * moveSpeed
            moveZ -= forwardZ * moveSpeed
        }
        if (event.key === Qt.Key_A) {
            moveX -= rightX * moveSpeed
            moveZ -= rightZ * moveSpeed
        }
        if (event.key === Qt.Key_D) {
            moveX += rightX * moveSpeed
            moveZ += rightZ * moveSpeed
        }

        playerCube.x += moveX
        playerCube.z += moveZ

        event.accepted = true
    }

    Component.onCompleted: {
        forceActiveFocus()
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
