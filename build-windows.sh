#!/bin/bash

echo "Building HaipX for Windows using Docker..."

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Строим Docker образ для Windows
echo "Building Windows Docker image..."
docker build -f Dockerfile.windows -t haipx-windows .

if [ $? -ne 0 ]; then
    echo "Error: Failed to build Docker image"
    exit 1
fi

# Создаем директорию для сборки
mkdir -p build-windows

# Собираем проект
echo "Building HaipX for Windows..."
docker run --rm -v$(pwd):/project haipx-windows bash -c "
    cd build-windows
    cmake -DCMAKE_TOOLCHAIN_FILE=../windows-toolchain.cmake ..
    make -j$(nproc)
"

if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
    echo "Windows executable: build-windows/HaipX.exe"
    echo "Resource files: build-windows/res/"
else
    echo "Error: Build failed"
    exit 1
fi 