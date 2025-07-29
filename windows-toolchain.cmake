# Windows cross-compilation toolchain
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

# Set pkg-config to use cross-compilation
set(PKG_CONFIG_EXECUTABLE x86_64-w64-mingw32-pkg-config)

# Set library and include paths
set(CMAKE_LIBRARY_PATH ${CMAKE_FIND_ROOT_PATH}/lib)
set(CMAKE_INCLUDE_PATH ${CMAKE_FIND_ROOT_PATH}/include)

# Add explicit include paths for Windows headers
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I${CMAKE_FIND_ROOT_PATH}/include -I/usr/x86_64-w64-mingw32/include")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${CMAKE_FIND_ROOT_PATH}/include -I/usr/x86_64-w64-mingw32/include")

# Add system include paths
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -isystem /usr/x86_64-w64-mingw32/include")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -isystem /usr/x86_64-w64-mingw32/include")

# Disable some find modules that don't work well with cross-compilation
set(CMAKE_DISABLE_FIND_PACKAGE_PkgConfig TRUE)

# Set compiler flags to avoid Linux headers
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I/usr/x86_64-w64-mingw32/include")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I/usr/x86_64-w64-mingw32/include") 