import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Input 2.15
import Qt3D.Extras 2.15
import QtQuick.Scene3D 2.15
import QtQuick.Shapes 1.15

Window {
    id: gameWindow
    width: 1280
    height: 720
    visible: true
    title: "Qt3D Explorer"
    color: "#1a1a2e"

    // ─── Game State ───────────────────────────────────────────────────────────
    property real playerX: 0
    property real playerY: 0       // vertical offset (for future jumping)
    property real playerZ: 0
    property real playerSpeed: 8.0

    // Camera orbit angles (degrees)
    property real camYaw:   0      // horizontal rotation around player
    property real camPitch: -20    // vertical tilt (negative = looking down)
    property real camDist:  6      // distance from player

    // Key state
    property bool keyW: false
    property bool keyS: false
    property bool keyA: false
    property bool keyD: false

    // Mouse look
    property bool mouseCaptured: false
    property real lastMouseX: 0
    property real lastMouseY: 0
    property real mouseSensitivity: 0.25

    // Stats
    property int fps: 0
    property int frameCount: 0
    property real fpsTimer: 0

    // ─── Input capture overlay ────────────────────────────────────────────────
    MouseArea {
        id: mouseCapture
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: {
            if (!gameWindow.mouseCaptured) {
                gameWindow.mouseCaptured = true
                gameWindow.lastMouseX = mouseX
                gameWindow.lastMouseY = mouseY
                cursorShape = Qt.BlankCursor
            }
        }

        onPositionChanged: (mouse) => {
            if (gameWindow.mouseCaptured) {
                var dx = mouse.x - gameWindow.lastMouseX
                var dy = mouse.y - gameWindow.lastMouseY

                gameWindow.camYaw   += dx * gameWindow.mouseSensitivity
                gameWindow.camPitch += dy * gameWindow.mouseSensitivity

                // Clamp pitch
                if (gameWindow.camPitch < -80) gameWindow.camPitch = -80
                if (gameWindow.camPitch >  10) gameWindow.camPitch =  10

                // Warp cursor back to centre to allow infinite rotation
                gameWindow.lastMouseX = gameWindow.width  / 2
                gameWindow.lastMouseY = gameWindow.height / 2
            }
        }
    }

    // ─── Key handling ─────────────────────────────────────────────────────────
    // Window doesn't have a focus property; use a transparent Item overlay instead
    Item {
        id: keyHandler
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            switch (event.key) {
                case Qt.Key_W: gameWindow.keyW = true;  break
                case Qt.Key_S: gameWindow.keyS = true;  break
                case Qt.Key_A: gameWindow.keyA = true;  break
                case Qt.Key_D: gameWindow.keyD = true;  break
                case Qt.Key_Escape:
                    gameWindow.mouseCaptured = false
                    mouseCapture.cursorShape = Qt.ArrowCursor
                    break
            }
            event.accepted = true
        }
        Keys.onReleased: (event) => {
            switch (event.key) {
                case Qt.Key_W: gameWindow.keyW = false; break
                case Qt.Key_S: gameWindow.keyS = false; break
                case Qt.Key_A: gameWindow.keyA = false; break
                case Qt.Key_D: gameWindow.keyD = false; break
            }
            event.accepted = true
        }
    }

    // ─── Game loop timer ──────────────────────────────────────────────────────
    Timer {
        id: gameLoop
        interval: 16   // ~60 fps
        repeat: true
        running: true

        onTriggered: {
            var dt = interval / 1000.0

            // Forward vector (from camYaw only – no pitch in movement)
            var yawRad = gameWindow.camYaw * Math.PI / 180.0
            var fwdX =  Math.sin(yawRad)
            var fwdZ = -Math.cos(yawRad)   // -Z is "into screen" in Qt3D

            // Right vector (perpendicular in XZ plane)
            var rightX =  Math.cos(yawRad)
            var rightZ =  Math.sin(yawRad)

            var mx = 0, mz = 0
            if (gameWindow.keyW) { mx += fwdX;  mz += fwdZ  }
            if (gameWindow.keyS) { mx -= fwdX;  mz -= fwdZ  }
            if (gameWindow.keyA) { mx -= rightX; mz -= rightZ }
            if (gameWindow.keyD) { mx += rightX; mz += rightZ }

            // Normalise diagonal movement
            var len = Math.sqrt(mx*mx + mz*mz)
            if (len > 0.001) {
                mx /= len; mz /= len
            }

            gameWindow.playerX += mx * gameWindow.playerSpeed * dt
            gameWindow.playerZ += mz * gameWindow.playerSpeed * dt

            // Boundary clamp
            var bound = 22
            if (gameWindow.playerX < -bound) gameWindow.playerX = -bound
            if (gameWindow.playerX >  bound) gameWindow.playerX =  bound
            if (gameWindow.playerZ < -bound) gameWindow.playerZ = -bound
            if (gameWindow.playerZ >  bound) gameWindow.playerZ =  bound

            // FPS
            gameWindow.frameCount++
            gameWindow.fpsTimer += dt
            if (gameWindow.fpsTimer >= 1.0) {
                gameWindow.fps = gameWindow.frameCount
                gameWindow.frameCount = 0
                gameWindow.fpsTimer -= 1.0
            }

            // Nudge Scene3D to repaint
            scene3d.visible = !scene3d.visible
            scene3d.visible = !scene3d.visible
        }
    }

    // ─── 3-D Scene ────────────────────────────────────────────────────────────
    Scene3D {
        id: scene3d
        anchors.fill: parent
        aspects: ["render", "logic", "input"]
        multisample: true
        hoverEnabled: false

        Entity {
            id: rootEntity

            // ── RenderSettings ──────────────────────────────────────────────
            components: [
                RenderSettings {
                    activeFrameGraph: ForwardRenderer {
                        id: forwardRenderer
                        clearColor: "#16213e"
                        camera: mainCamera
                    }
                }
            ]

            // ── Camera ──────────────────────────────────────────────────────
            Camera {
                id: mainCamera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 70
                aspectRatio: gameWindow.width / gameWindow.height
                nearPlane: 0.1
                farPlane: 500

                // Orbit position computed from player pos + angles + distance
                property real yawRad:   gameWindow.camYaw   * Math.PI / 180
                property real pitchRad: gameWindow.camPitch * Math.PI / 180
                property real d:        gameWindow.camDist

                // Offset from player (behind and slightly above)
                property real offX: -d * Math.sin(yawRad) * Math.cos(pitchRad)
                property real offY:  d * Math.sin(-pitchRad) + 1.6
                property real offZ:  d * Math.cos(yawRad) * Math.cos(pitchRad)

                position: Qt.vector3d(
                    gameWindow.playerX + offX,
                    offY,
                    gameWindow.playerZ + offZ
                )
                viewCenter: Qt.vector3d(
                    gameWindow.playerX,
                    1.0,
                    gameWindow.playerZ
                )
                upVector: Qt.vector3d(0, 1, 0)
            }

            // ── Lighting ────────────────────────────────────────────────────
            Entity {
                components: [
                    DirectionalLight {
                        worldDirection: Qt.vector3d(-0.4, -1.0, -0.5)
                        color:     "#fff8e7"
                        intensity: 1.0
                    }
                ]
            }
            Entity {
                components: [
                    PointLight {
                        color:     "#4466ff"
                        intensity: 0.4
                        constantAttenuation: 1.0
                        linearAttenuation:   0.05
                        quadraticAttenuation: 0.005
                    },
                    Transform { translation: Qt.vector3d(0, 8, 0) }
                ]
            }

            // ── Ground plane ─────────────────────────────────────────────────
            Entity {
                id: groundEntity
                components: [
                    PlaneMesh {
                        width:  50
                        height: 50
                    },
                    PhongMaterial {
                        diffuse:  "#2d5a27"
                        specular: "#1a3d14"
                        shininess: 5.0
                        ambient:  "#1a3d14"
                    },
                    Transform {
                        translation: Qt.vector3d(0, 0, 0)
                    }
                ]
            }

            // ── Grid lines on ground (flat box strips) ───────────────────────
            Entity {
                id: gridEntity

                // We'll create a series of thin boxes to form a grid
                NodeInstantiator {
                    model: 11   // 11 lines in each direction
                    delegate: Entity {
                        property int lineIdx: index
                        property real pos: (lineIdx - 5) * 5.0

                        // X-axis line
                        Entity {
                            components: [
                                CuboidMesh { xExtent: 50; yExtent: 0.03; zExtent: 0.06 },
                                PhongMaterial {
                                    diffuse: "#3d7a35"
                                    ambient: "#2a5225"
                                    specular: "#000"
                                    shininess: 0
                                },
                                Transform { translation: Qt.vector3d(0, 0.02, pos) }
                            ]
                        }
                        // Z-axis line
                        Entity {
                            components: [
                                CuboidMesh { xExtent: 0.06; yExtent: 0.03; zExtent: 50 },
                                PhongMaterial {
                                    diffuse: "#3d7a35"
                                    ambient: "#2a5225"
                                    specular: "#000"
                                    shininess: 0
                                },
                                Transform { translation: Qt.vector3d(pos, 0.02, 0) }
                            ]
                        }
                    }
                }
            }

            // ── Player model ─────────────────────────────────────────────────
            Entity {
                id: playerEntity

                // Body (capsule approximation: cylinder + 2 spheres)
                // — Torso
                Entity {
                    components: [
                        CylinderMesh { radius: 0.35; length: 1.1; rings: 8; slices: 16 },
                        PhongMaterial {
                            diffuse:  "#e63946"
                            specular: "#ff6b6b"
                            shininess: 40
                            ambient:  "#7a1c22"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX,
                                0.9,
                                gameWindow.playerZ)
                        }
                    ]
                }
                // — Head
                Entity {
                    components: [
                        SphereMesh { radius: 0.32; rings: 12; slices: 16 },
                        PhongMaterial {
                            diffuse:  "#f4a261"
                            specular: "#ffd6b0"
                            shininess: 60
                            ambient:  "#7a4f2e"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX,
                                1.85,
                                gameWindow.playerZ)
                        }
                    ]
                }
                // — Left leg
                Entity {
                    components: [
                        CylinderMesh { radius: 0.15; length: 0.9; rings: 4; slices: 12 },
                        PhongMaterial {
                            diffuse:  "#457b9d"
                            specular: "#74b9d6"
                            shininess: 30
                            ambient:  "#1d3a4e"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX - 0.18,
                                0.25,
                                gameWindow.playerZ)
                        }
                    ]
                }
                // — Right leg
                Entity {
                    components: [
                        CylinderMesh { radius: 0.15; length: 0.9; rings: 4; slices: 12 },
                        PhongMaterial {
                            diffuse:  "#457b9d"
                            specular: "#74b9d6"
                            shininess: 30
                            ambient:  "#1d3a4e"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX + 0.18,
                                0.25,
                                gameWindow.playerZ)
                        }
                    ]
                }
                // — Left arm
                Entity {
                    components: [
                        CylinderMesh { radius: 0.11; length: 0.9; rings: 4; slices: 12 },
                        PhongMaterial {
                            diffuse:  "#e63946"
                            specular: "#ff8888"
                            shininess: 30
                            ambient:  "#7a1c22"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX - 0.52,
                                0.9,
                                gameWindow.playerZ)
                            rotationZ: 15
                        }
                    ]
                }
                // — Right arm
                Entity {
                    components: [
                        CylinderMesh { radius: 0.11; length: 0.9; rings: 4; slices: 12 },
                        PhongMaterial {
                            diffuse:  "#e63946"
                            specular: "#ff8888"
                            shininess: 30
                            ambient:  "#7a1c22"
                        },
                        Transform {
                            translation: Qt.vector3d(
                                gameWindow.playerX + 0.52,
                                0.9,
                                gameWindow.playerZ)
                            rotationZ: -15
                        }
                    ]
                }
            }

            // ── Scatter some boxes as landmarks ─────────────────────────────
            NodeInstantiator {
                model: ListModel {
                    // [x, z, r, g, b, sx, sy, sz]
                    ListElement { bx:-8; bz: 6; br:0.2; bg:0.6; bb:0.9; sx:1.2; sy:2.4; sz:1.2 }
                    ListElement { bx: 8; bz:-6; br:0.9; bg:0.4; bb:0.2; sx:1.5; sy:1.5; sz:1.5 }
                    ListElement { bx:-4; bz:-10;br:0.8; bg:0.2; bb:0.8; sx:1.0; sy:3.0; sz:1.0 }
                    ListElement { bx:12; bz: 4; br:0.2; bg:0.8; bb:0.4; sx:2.0; sy:1.0; sz:2.0 }
                    ListElement { bx:-12;bz:-4; br:0.9; bg:0.8; bb:0.1; sx:1.8; sy:1.8; sz:1.8 }
                    ListElement { bx: 5; bz:12; br:0.3; bg:0.7; bb:0.9; sx:1.0; sy:2.0; sz:1.0 }
                    ListElement { bx:-5; bz:-12;br:0.7; bg:0.3; bb:0.2; sx:2.5; sy:0.8; sz:2.5 }
                    ListElement { bx:15; bz:-10;br:0.5; bg:0.9; bb:0.3; sx:1.0; sy:4.0; sz:1.0 }
                }
                delegate: Entity {
                    components: [
                        CuboidMesh {
                            xExtent: model.sx
                            yExtent: model.sy
                            zExtent: model.sz
                        },
                        PhongMaterial {
                            diffuse:  Qt.rgba(model.br, model.bg, model.bb, 1)
                            specular: Qt.rgba(model.br*0.5+0.3, model.bg*0.5+0.3, model.bb*0.5+0.3, 1)
                            shininess: 50
                            ambient:  Qt.rgba(model.br*0.2, model.bg*0.2, model.bb*0.2, 1)
                        },
                        Transform {
                            translation: Qt.vector3d(model.bx, model.sy / 2.0, model.bz)
                        }
                    ]
                }
            }

        } // rootEntity
    } // Scene3D

    // ─── HUD Layer ────────────────────────────────────────────────────────────
    // Semi-transparent top bar
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 44
        color: Qt.rgba(0, 0, 0, 0.55)

        Row {
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
            spacing: 20

            Text {
                text: "Qt3D Explorer"
                color: "#e0e0e0"
                font { pixelSize: 18; bold: true; family: "Monospace" }
            }
            Text {
                text: "FPS: " + gameWindow.fps
                color: gameWindow.fps >= 50 ? "#4ade80" : gameWindow.fps >= 30 ? "#facc15" : "#f87171"
                font { pixelSize: 14; family: "Monospace" }
            }
        }

        Row {
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            spacing: 20

            Text {
                text: "Pos: (" + gameWindow.playerX.toFixed(1) + ", " + gameWindow.playerZ.toFixed(1) + ")"
                color: "#a0c4ff"
                font { pixelSize: 13; family: "Monospace" }
            }
            Text {
                text: "Cam: " + gameWindow.camYaw.toFixed(0) + "° / " + gameWindow.camPitch.toFixed(0) + "°"
                color: "#a0c4ff"
                font { pixelSize: 13; family: "Monospace" }
            }
        }
    }

    // Crosshair
    Item {
        anchors.centerIn: parent
        visible: gameWindow.mouseCaptured
        width: 20; height: 20

        Rectangle { anchors.centerIn: parent; width: 14; height: 2; color: "white"; opacity: 0.85 }
        Rectangle { anchors.centerIn: parent; width: 2; height: 14; color: "white"; opacity: 0.85 }
        Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: "#00ff88"; opacity: 0.9 }
    }

    // WASD movement indicator (bottom-left)
    Item {
        anchors { bottom: parent.bottom; left: parent.left; margins: 20 }
        width: 90; height: 90

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0,0,0,0.5)
            radius: 10
        }

        // W
        Rectangle {
            x: 30; y: 4; width: 26; height: 26; radius: 5
            color: gameWindow.keyW ? "#4ade80" : Qt.rgba(1,1,1,0.15)
            border.color: Qt.rgba(1,1,1,0.3); border.width: 1
            Text { anchors.centerIn: parent; text: "W"; color: "white"; font.pixelSize: 13; font.bold: true }
        }
        // A
        Rectangle {
            x: 2; y: 32; width: 26; height: 26; radius: 5
            color: gameWindow.keyA ? "#4ade80" : Qt.rgba(1,1,1,0.15)
            border.color: Qt.rgba(1,1,1,0.3); border.width: 1
            Text { anchors.centerIn: parent; text: "A"; color: "white"; font.pixelSize: 13; font.bold: true }
        }
        // S
        Rectangle {
            x: 30; y: 32; width: 26; height: 26; radius: 5
            color: gameWindow.keyS ? "#4ade80" : Qt.rgba(1,1,1,0.15)
            border.color: Qt.rgba(1,1,1,0.3); border.width: 1
            Text { anchors.centerIn: parent; text: "S"; color: "white"; font.pixelSize: 13; font.bold: true }
        }
        // D
        Rectangle {
            x: 58; y: 32; width: 26; height: 26; radius: 5
            color: gameWindow.keyD ? "#4ade80" : Qt.rgba(1,1,1,0.15)
            border.color: Qt.rgba(1,1,1,0.3); border.width: 1
            Text { anchors.centerIn: parent; text: "D"; color: "white"; font.pixelSize: 13; font.bold: true }
        }

        Text {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
            text: "Move"
            color: Qt.rgba(1,1,1,0.5)
            font.pixelSize: 10
        }
    }

    // Click-to-capture / ESC hint (bottom-right)
    Rectangle {
        anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
        width: hintText.implicitWidth + 24
        height: 32
        radius: 8
        color: Qt.rgba(0, 0, 0, 0.55)
        visible: !gameWindow.mouseCaptured

        Text {
            id: hintText
            anchors.centerIn: parent
            text: "🖱  Click to capture mouse"
            color: "#e0e0e0"
            font.pixelSize: 13
        }
    }
    Rectangle {
        anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
        width: escHint.implicitWidth + 24
        height: 32
        radius: 8
        color: Qt.rgba(0, 0, 0, 0.55)
        visible: gameWindow.mouseCaptured

        Text {
            id: escHint
            anchors.centerIn: parent
            text: "ESC  Release mouse"
            color: "#a0a0a0"
            font.pixelSize: 13
        }
    }
}
