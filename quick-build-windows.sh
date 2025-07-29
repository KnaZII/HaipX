#!/bin/bash

# Быстрая сборка HaipX для Windows через Docker
# Использование: ./quick-build-windows.sh

echo "🚀 Быстрая сборка HaipX для Windows..."

# Проверяем Docker
if ! sudo docker info &> /dev/null; then
    echo "❌ Docker не запущен"
    exit 1
fi

# Собираем образ (если еще не собран)
echo "📦 Проверяем Docker образ..."
if ! sudo docker image inspect haipx-windows &> /dev/null; then
    echo "🔨 Собираем Docker образ..."
    sudo docker build -f Dockerfile.windows -t haipx-windows .
fi

# Собираем проект
echo "🔨 Собираем проект..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
          -Bbuild-windows && \
    cmake --build build-windows -j$(nproc)
"

# Копируем файлы
echo "📁 Копируем файлы..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
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