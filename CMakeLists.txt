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

# Find vcpkg packages
find_package(glfw3 CONFIG REQUIRED)
find_package(GLEW CONFIG REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(libpng CONFIG REQUIRED)
find_package(zlib CONFIG REQUIRED)
find_package(openal-soft CONFIG REQUIRED)
find_package(CURL CONFIG REQUIRED)
find_package(LuaJIT CONFIG REQUIRED)
find_package(EnTT CONFIG REQUIRED)

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
    PRIVATE glfw
    PRIVATE GLEW::GLEW
    PRIVATE glm::glm
    PRIVATE libpng::libpng
    PRIVATE ZLIB::ZLIB
    PRIVATE OpenAL::OpenAL
    PRIVATE CURL::libcurl
    PRIVATE LuaJIT::LuaJIT
    PRIVATE EnTT::EnTT
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