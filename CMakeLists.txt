cmake_minimum_required(VERSION 3.21)

# This line manipulated by set-versions.sh, coordinate changes there.
project(circuit-cell VERSION 2026.3.1777 LANGUAGES CXX)

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
    3DCore
    3DRender
    3DExtras
)

qt_standard_project_setup()

qt_add_resources(RESOURCES qml/resources.qrc)

qt_add_executable(circuit-cell
    src/main.cpp
    src/MainWindow.cpp
    src/MainWindow.hpp
    ${RESOURCES}   # include the QML resources
)

# Enable the .app build on MacOS targets.
set_target_properties(circuit-cell PROPERTIES MACOSX_BUNDLE TRUE)

# Ensure we link to Qt6::Quick for QML processing
find_package(Qt6 REQUIRED COMPONENTS
    QuickWidgets
    Widgets
    Quick
    QuickControls2
)

target_link_libraries(circuit-cell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    Qt6::QmlIntegration
    Qt6::QuickWidgets
    Qt6::OpenGL
    Qt6::Network
    Qt6::Concurrent
    Qt6::3DCore
    Qt6::3DRender
    Qt6::3DExtras
    Qt6::3DInput
    Qt6::3DLogic
)

install(TARGETS circuit-cell
    BUNDLE DESTINATION bundle
    RUNTIME DESTINATION bin
)

