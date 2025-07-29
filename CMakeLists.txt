cmake_minimum_required(VERSION 3.5)
project(HaipX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

execute_process(COMMAND ${CMAKE_COMMAND} --version)

option(HAIPX_BUILD_APPDIR "Pack linux build" OFF)
option(HAIPX_BUILD_TESTS "Build tests" OFF)

# Need for static compilation on Windows with MSVC clang TODO: Make single build
# on Windows to avoid dependence on combinations of platforms and compilers and
# make it independent
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # We use two types linking: for clang build is static (vcpkg triplet
    # x64-windows-static) and for msvc build is dynamic linking (vcpkg triplet
    # x64-windows) By default CMAKE_MSVC_RUNTIME_LIBRARY set by
    # MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    if(VCPKG_TARGET_TRIPLET MATCHES "static")
        # Need for MSVC clang
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    endif()
endif()

add_subdirectory(src)
add_executable(HaipX src/main.cpp)

if(HAIPX_BUILD_APPDIR)
    include(${CMAKE_CURRENT_SOURCE_DIR}/dev/cmake/BuildAppdir.cmake)
endif()

target_link_libraries(HaipX PRIVATE HaipXSrc
                                          $<$<PLATFORM_ID:Windows>:winmm>)

target_link_options(HaipX PRIVATE $<$<CXX_COMPILER_ID:GNU>:-no-pie>)

# Deploy res to build dir
add_custom_command(
    TARGET HaipX
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/res $<TARGET_FILE_DIR:HaipX>/res)

if(HAIPX_BUILD_TESTS)
    enable_testing()
    add_subdirectory(test)
endif()

add_subdirectory(vctest)
