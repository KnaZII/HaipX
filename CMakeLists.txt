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

# Add source files using GLOB
file(GLOB_RECURSE ALL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
file(GLOB_RECURSE ALL_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp)

# Remove main.cpp from sources for library
list(REMOVE_ITEM ALL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

add_library(HaipXSrc STATIC ${ALL_SOURCES} ${ALL_HEADERS})

# Include directories
target_include_directories(HaipXSrc PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Create main executable
add_executable(HaipX src/main.cpp)
target_link_libraries(HaipX PRIVATE HaipXSrc)

# Link Windows libraries
if(WIN32)
    target_link_libraries(HaipX PRIVATE 
        kernel32 
        user32 
        gdi32 
        winmm 
        ws2_32 
        iphlpapi
    )
endif()

# Copy resources
add_custom_command(
    TARGET HaipX
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/res $<TARGET_FILE_DIR:HaipX>/res) 