#!/bin/bash

# Упрощенная сборка HaipX для Windows через Docker
# Использование: ./build-windows-simple.sh

echo "🚀 Упрощенная сборка HaipX для Windows..."

# Проверяем Docker
if ! sudo docker info &> /dev/null; then
    echo "❌ Docker не запущен"
    exit 1
fi

# Собираем образ (если еще не собран)
echo "📦 Проверяем Docker образ..."
if ! sudo docker image inspect haipx-windows-simple &> /dev/null; then
    echo "🔨 Собираем Docker образ..."
    sudo docker build -f Dockerfile.windows.simple -t haipx-windows-simple .
fi

# Собираем проект
echo "🔨 Собираем проект..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows-simple bash -c "
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
          -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-x86_64-w64-mingw32.cmake \
          -Bbuild-windows && \
    cmake --build build-windows -j$(nproc)
"

# Копируем файлы
echo "📁 Копируем файлы..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows-simple bash -c "
    if [ -f build-windows/HaipX.exe ]; then
        cp build-windows/HaipX.exe . && \
        cp -r res . && \
        echo '✅ Готово!'
    else
        echo '❌ Ошибка сборки'
        exit 1
    fi
"

echo "�� Сборка завершена!" 