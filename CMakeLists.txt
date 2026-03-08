cmake_minimum_required(VERSION 3.21)

# This line manipulated by set-versions.sh, coordinate changes there.
project(circuit-cell VERSION 2026.3.1935 LANGUAGES CXX)

# if(DEFINED ENV{CI_PIPELINE_IID})
#     set(PROJECT_VERSION_PATCH 1745)
# endif()

configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/version.h.in
    ${CMAKE_BINARY_DIR}/generated/version.h
)

include_directories(${CMAKE_BINARY_DIR}/generated)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
)

qt_standard_project_setup()

# Ensure we link to Qt6::Quick for QML processing
find_package(Qt6 REQUIRED COMPONENTS
    Quick
    QuickWidgets
    Qml
    QmlIntegration
    Quick3D
    Svg
)

######### BEGIN TOOLS #########

add_executable(svg2png support_tools/svg2png.cpp)

target_link_libraries(svg2png
    Qt6::Gui
    Qt6::Svg
)

######### BEGIN RESOURCES #########

set(ICON_SVG ${CMAKE_SOURCE_DIR}/graphics/icon-256.svg)

set(ICON_16  ${CMAKE_BINARY_DIR}/icon-16.png)
set(ICON_32  ${CMAKE_BINARY_DIR}/icon-32.png)
set(ICON_48  ${CMAKE_BINARY_DIR}/icon-48.png)
set(ICON_96  ${CMAKE_BINARY_DIR}/icon-96.png)
set(ICON_128  ${CMAKE_BINARY_DIR}/icon-128.png)
set(ICON_256 ${CMAKE_BINARY_DIR}/icon-256.png)

add_custom_command(
    OUTPUT ${ICON_16} ${ICON_32} ${ICON_48} ${ICON_96} ${ICON_128} ${ICON_256}
    COMMAND rsvg-convert ${ICON_SVG} -w 16  -h 16  -o ${ICON_16}
    COMMAND rsvg-convert ${ICON_SVG} -w 32  -h 32  -o ${ICON_32}
    COMMAND rsvg-convert ${ICON_SVG} -w 48  -h 48  -o ${ICON_48}
    COMMAND rsvg-convert ${ICON_SVG} -w 96  -h 96  -o ${ICON_96}
    COMMAND rsvg-convert ${ICON_SVG} -w 128 -h 128 -o ${ICON_128}
    COMMAND rsvg-convert ${ICON_SVG} -w 256 -h 256 -o ${ICON_256}
    DEPENDS ${ICON_SVG}
)

set(ICON_ICO ${CMAKE_BINARY_DIR}/icon.ico)

add_custom_target(generate_icons
    DEPENDS
        ${ICON_16}
        ${ICON_32}
        ${ICON_48}
        ${ICON_96}
        ${ICON_128}
        ${ICON_256}
)

add_custom_command(
    OUTPUT ${ICON_ICO}
    COMMAND icotool -c ${ICON_16} ${ICON_32} ${ICON_48} ${ICON_96} ${ICON_128} ${ICON_256} -o ${ICON_ICO}
    DEPENDS generate_icons
)

set(APP_ICON_RESOURCE ${CMAKE_BINARY_DIR}/circuit-cell.rc)

# Windows resource file generation
file(WRITE ${APP_ICON_RESOURCE}
"IDI_ICON1 ICON \"${ICON_ICO}\"")

######### BEGIN GAME #########

qt_add_resources(RESOURCES qml/resources.qrc)

qt_add_executable(circuit-cell
    src/main.cpp
    src/MainWindow.cpp
    src/MainWindow.hpp
    ${RESOURCES}   # include the QML resources
)

# Embed generated icon files
set_source_files_properties(${ICON_16}  PROPERTIES QT_RESOURCE_ALIAS "icon-16.png")
set_source_files_properties(${ICON_32}  PROPERTIES QT_RESOURCE_ALIAS "icon-32.png")
set_source_files_properties(${ICON_48}  PROPERTIES QT_RESOURCE_ALIAS "icon-48.png")
set_source_files_properties(${ICON_96}  PROPERTIES QT_RESOURCE_ALIAS "icon-96.png")
set_source_files_properties(${ICON_128} PROPERTIES QT_RESOURCE_ALIAS "icon-128.png")
set_source_files_properties(${ICON_256} PROPERTIES QT_RESOURCE_ALIAS "icon-256.png")
qt_add_resources(circuit-cell generated_resources
    PREFIX "/icons"
    FILES
        ${ICON_16}
        ${ICON_32}
        ${ICON_48}
        ${ICON_96}
        ${ICON_128}
        ${ICON_256}
)
add_dependencies(circuit-cell generate_icons)


# Enable the .app build on MacOS targets.
set_target_properties(circuit-cell PROPERTIES MACOSX_BUNDLE TRUE)


target_link_libraries(circuit-cell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::Qml
    Qt6::QmlIntegration
    Qt6::QuickWidgets
    Qt6::Quick3D
)

target_sources(circuit-cell PRIVATE ${APP_ICON_RESOURCE})

install(TARGETS circuit-cell
    BUNDLE DESTINATION bundle
    RUNTIME DESTINATION bin
)

