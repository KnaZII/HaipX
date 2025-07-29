cmake_minimum_required(VERSION 3.5)
project(HaipX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Windows cross-compilation settings
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Specify the cross compiler
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Set the root path for finding libraries
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)

# Search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Disable pkg-config for Windows
set(CMAKE_DISABLE_FIND_PACKAGE_PkgConfig TRUE)

# Set library and include paths
set(CMAKE_LIBRARY_PATH ${CMAKE_FIND_ROOT_PATH}/lib)
set(CMAKE_INCLUDE_PATH ${CMAKE_FIND_ROOT_PATH}/include)

# Add Windows-specific compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DWIN32 -D_WINDOWS -DWIN32_LEAN_AND_MEAN -I/usr/x86_64-w64-mingw32/include -isystem /usr/x86_64-w64-mingw32/include")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DWIN32 -D_WINDOWS -DWIN32_LEAN_AND_MEAN -I/usr/x86_64-w64-mingw32/include -isystem /usr/x86_64-w64-mingw32/include")

# Find required packages manually
find_path(GLEW_INCLUDE_DIR GL/glew.h
    PATHS ${CMAKE_FIND_ROOT_PATH}/include
    NO_DEFAULT_PATH
)

find_library(GLEW_LIBRARY
    NAMES glew32
    PATHS ${CMAKE_FIND_ROOT_PATH}/lib
    NO_DEFAULT_PATH
)

find_path(GLFW_INCLUDE_DIR GLFW/glfw3.h
    PATHS ${CMAKE_FIND_ROOT_PATH}/include
    NO_DEFAULT_PATH
)

find_library(GLFW_LIBRARY
    NAMES glfw3
    PATHS ${CMAKE_FIND_ROOT_PATH}/lib
    NO_DEFAULT_PATH
)

find_path(GLM_INCLUDE_DIR glm/glm.hpp
    PATHS ${CMAKE_FIND_ROOT_PATH}/include
    NO_DEFAULT_PATH
)

# Create imported targets
add_library(GLEW::GLEW UNKNOWN IMPORTED)
set_target_properties(GLEW::GLEW PROPERTIES
    IMPORTED_LOCATION ${GLEW_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${GLEW_INCLUDE_DIR}
)

add_library(glfw UNKNOWN IMPORTED)
set_target_properties(glfw PROPERTIES
    IMPORTED_LOCATION ${GLFW_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${GLFW_INCLUDE_DIR}
)

add_library(glm INTERFACE IMPORTED)
set_target_properties(glm PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${GLM_INCLUDE_DIR}
)

# Add source files
file(GLOB_RECURSE headers ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp)
file(GLOB_RECURSE sources ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
list(REMOVE_ITEM sources ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

add_library(HaipXSrc STATIC ${sources} ${headers})

# Include directories
target_include_directories(HaipXSrc PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Link libraries
target_link_libraries(HaipXSrc
    PRIVATE glfw
            GLEW::GLEW
            opengl32
            winmm
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