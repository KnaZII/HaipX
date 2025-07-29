cmake_minimum_required(VERSION 3.5)
project(HaipX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Windows-specific settings
if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DWIN32 /D_WINDOWS /DWIN32_LEAN_AND_MEAN")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /DWIN32 /D_WINDOWS /DWIN32_LEAN_AND_MEAN")
endif()

# Find packages
find_package(OpenGL REQUIRED)
find_package(PkgConfig QUIET)

# Try to find GLFW
find_package(glfw3 QUIET)
if(NOT glfw3_FOUND)
    # Fallback: try to find GLFW manually
    find_path(GLFW_INCLUDE_DIR GLFW/glfw3.h)
    find_library(GLFW_LIBRARY glfw3)
    if(GLFW_INCLUDE_DIR AND GLFW_LIBRARY)
        add_library(glfw UNKNOWN IMPORTED)
        set_target_properties(glfw PROPERTIES
            IMPORTED_LOCATION ${GLFW_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${GLFW_INCLUDE_DIR}
        )
    endif()
endif()

# Try to find GLEW
find_package(GLEW QUIET)
if(NOT GLEW_FOUND)
    # Fallback: try to find GLEW manually
    find_path(GLEW_INCLUDE_DIR GL/glew.h)
    find_library(GLEW_LIBRARY glew32)
    if(GLEW_INCLUDE_DIR AND GLEW_LIBRARY)
        add_library(GLEW::GLEW UNKNOWN IMPORTED)
        set_target_properties(GLEW::GLEW PROPERTIES
            IMPORTED_LOCATION ${GLEW_LIBRARY}
            INTERFACE_INCLUDE_DIRECTORIES ${GLEW_INCLUDE_DIR}
        )
    endif()
endif()

# Try to find GLM
find_package(glm QUIET)
if(NOT glm_FOUND)
    # Fallback: try to find GLM manually
    find_path(GLM_INCLUDE_DIR glm/glm.hpp)
    if(GLM_INCLUDE_DIR)
        add_library(glm INTERFACE IMPORTED)
        set_target_properties(glm PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${GLM_INCLUDE_DIR}
        )
    endif()
endif()

# Add source files
file(GLOB_RECURSE headers ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp)
file(GLOB_RECURSE sources ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
list(REMOVE_ITEM sources ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

add_library(HaipXSrc STATIC ${sources} ${headers})

# Include directories
target_include_directories(HaipXSrc PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Link libraries
target_link_libraries(HaipXSrc
    PRIVATE OpenGL::GL
    PUBLIC glm
)

# Create main executable
add_executable(HaipX src/main.cpp)
target_link_libraries(HaipX PRIVATE HaipXSrc)

# Copy resources
add_custom_command(
    TARGET HaipX
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/res $<TARGET_FILE_DIR:HaipX>/res) 