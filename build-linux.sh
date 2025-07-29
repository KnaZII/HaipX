#!/bin/bash

echo "Building HaipX for Linux..."

# Проверяем, установлены ли необходимые пакеты
echo "Checking dependencies..."

# Список необходимых пакетов
PACKAGES=(
    "build-essential"
    "cmake"
    "libpng-dev"
    "zlib1g-dev"
    "libopenal-dev"
    "libcurl4-openssl-dev"
    "libluajit-5.1-dev"
    "libglfw3-dev"
    "libglew-dev"
    "libglm-dev"
)

# Проверяем каждый пакет
for package in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Warning: Package $package is not installed"
        echo "You may need to run: sudo apt-get install $package"
    fi
done

# Создаем директорию для сборки
mkdir -p build-linux

# Собираем проект
echo "Building HaipX for Linux..."
cd build-linux
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
    echo "Linux executable: build-linux/HaipX"
    echo "Resource files: build-linux/res/"
else
    echo "Error: Build failed"
    exit 1
fi 