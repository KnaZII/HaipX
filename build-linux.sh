#!/bin/bash

# Сборка HaipX для Linux через Docker
# Использование: ./build-linux.sh

echo "🚀 Сборка HaipX для Linux..."

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

# Собираем проект для Linux
echo "🔨 Собираем проект для Linux..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows-simple bash -c "
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
          -Bbuild-linux && \
    cmake --build build-linux -j$(nproc)
"

# Копируем файлы
echo "📁 Копируем файлы..."
sudo docker run --rm -it -v$(pwd):/project haipx-windows-simple bash -c "
    if [ -f build-linux/HaipX ]; then
        cp build-linux/HaipX ./HaipX-linux && \
        cp -r build-linux/res ./res-linux && \
        echo '✅ Готово!'
    else
        echo '❌ Ошибка сборки'
        exit 1
    fi
"

echo "🎉 Сборка завершена!"
echo "📂 Файлы для Linux:"
echo "   - HaipX-linux (исполняемый файл)"
echo "   - res-linux/ (папка с ресурсами)" 