cmake_minimum_required(VERSION 3.20)
project(QPlayer VERSION 1.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(Qt6 REQUIRED COMPONENTS
        Core
        Quick
        Multimedia
        QuickControls2
        Charts
)
qt_standard_project_setup()
set(QT6_CREATE_TARGET_TYPE EXECUTABLE)
set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/app_icon.ico")
qt_add_executable(QPlayer
        main.cpp
        backend/PlayerController.h
        backend/PlayerController.cpp
        backend/MusicInfo.h
)
target_link_libraries(QPlayer PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Multimedia
        Qt6::QuickControls2
        Qt6::Charts
)
qt_add_qml_module(QPlayer
        URI QPlayer
        VERSION 1.0
        QML_FILES
        Main.qml
)
qt_finalize_target(QPlayer)
target_compile_definitions(QPlayer PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)
if(WIN32)
    set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/app_icon.ico")
    if(EXISTS "${APP_ICON}")
        set_target_properties(QPlayer PROPERTIES
                RC_ICONS "${APP_ICON}"
        )
        message(STATUS "Windows executable icon set: ${APP_ICON}")
    else()
        message(WARNING "Windows icon file not found: ${APP_ICON}")
    endif()
endif()
file(COPY assets/icons DESTINATION ${CMAKE_CURRENT_BINARY_DIR})