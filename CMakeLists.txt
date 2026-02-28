cmake_minimum_required(VERSION 3.21)

# This line manipulated by set-versions.sh, coordinate changes there.
project(circuit-cell VERSION 2026.2.1745 LANGUAGES CXX)

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

qt_add_executable(circuit-cell
    src/main.cpp
    src/MainWindow.cpp
)

# Enable the .app build on MacOS targets.
set_target_properties(circuit-cell PROPERTIES MACOSX_BUNDLE TRUE)


target_link_libraries(circuit-cell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::3DCore
    Qt6::3DRender
    Qt6::3DExtras
)

install(TARGETS circuit-cell
    BUNDLE DESTINATION bundle
    RUNTIME DESTINATION bin
)

