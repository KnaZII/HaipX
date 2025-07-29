#!/bin/bash

# Скрипт для сборки HaipX под Windows через Docker
# Использование: ./build-windows.sh

set -e

echo "🚀 Начинаем сборку HaipX для Windows через Docker..."

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Пожалуйста, установите Docker."
    exit 1
fi

# Проверяем, запущен ли Docker
if ! docker info &> /dev/null; then
    echo "❌ Docker не запущен. Пожалуйста, запустите Docker."
    exit 1
fi

echo "📦 Собираем Docker образ для Windows..."
docker build -f Dockerfile.windows -t haipx-windows .

echo "🔨 Собираем проект под Windows..."
docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
          -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-x86_64-w64-mingw32.cmake \
          -Bbuild-windows && \
    cmake --build build-windows -j$(nproc)
"

echo "📁 Копируем исполняемые файлы..."
docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
    if [ -f build-windows/HaipX.exe ]; then
        cp build-windows/HaipX.exe . && \
        cp -r res . && \
        echo '✅ HaipX.exe и ресурсы скопированы в текущую директорию'
    else
        echo '❌ HaipX.exe не найден в build-windows/'
        exit 1
    fi
"

echo "🎉 Сборка завершена успешно!"
echo "📂 Файлы для Windows:"
echo "   - HaipX.exe"
echo "   - res/ (папка с ресурсами)"

# Проверяем размер исполняемого файла
if [ -f HaipX.exe ]; then
    size=$(du -h HaipX.exe | cut -f1)
    echo "📊 Размер HaipX.exe: $size"
fi 