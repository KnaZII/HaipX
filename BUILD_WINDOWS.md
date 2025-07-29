# Сборка HaipX для Windows через Docker

Этот документ описывает, как собрать HaipX для Windows используя Docker.

## Требования

- Docker
- Linux или macOS (для запуска Docker)

## Быстрая сборка

### 1. Автоматическая сборка

Запустите скрипт для автоматической сборки:

```bash
./quick-build-windows.sh
```

Этот скрипт:
- Проверит наличие Docker
- Соберет Docker образ (если нужно)
- Скомпилирует проект
- Скопирует `HaipX.exe` и папку `res/` в текущую директорию

### 2. Ручная сборка

Если вы хотите выполнить сборку вручную:

```bash
# 1. Собрать Docker образ
docker build -f Dockerfile.windows -t haipx-windows .

# 2. Собрать проект
docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
          -Bbuild-windows && \
    cmake --build build-windows -j$(nproc)
"

# 3. Скопировать файлы
docker run --rm -it -v$(pwd):/project haipx-windows bash -c "
    cp build-windows/HaipX.exe . && \
    cp -r res .
"
```

## Результат сборки

После успешной сборки у вас будет:

- `HaipX.exe` - исполняемый файл для Windows
- `res/` - папка с ресурсами игры

## Устранение неполадок

### Docker не запущен
```bash
sudo systemctl start docker
```

### Ошибки сборки
1. Убедитесь, что у вас достаточно места на диске (требуется ~2GB)
2. Проверьте, что Docker имеет доступ к интернету
3. Попробуйте пересобрать образ: `docker build --no-cache -f Dockerfile.windows -t haipx-windows .`

### Проблемы с зависимостями
Если возникают проблемы с библиотеками, попробуйте:

```bash
# Очистить Docker кэш
docker system prune -a

# Пересобрать образ
docker build --no-cache -f Dockerfile.windows -t haipx-windows .
```

## Тестирование

Для тестирования собранного файла в Windows:

1. Скопируйте `HaipX.exe` и папку `res/` на Windows машину
2. Запустите `HaipX.exe`

## Структура Dockerfile

Dockerfile.windows содержит:

- **Базовый образ**: Debian Bookworm
- **Компилятор**: MinGW-w64 для кросс-компиляции
- **Библиотеки**: GLFW, GLEW, GLM, libpng, OpenAL, libcurl, libvorbis
- **Инструменты**: CMake, Git, Wget

## Оптимизация

Для ускорения сборки:

- Используйте `./quick-build-windows.sh` для повторных сборок
- Docker образ кэшируется между сборками
- Используйте `-j$(nproc)` для параллельной компиляции 