#include "MenuScreen.hpp"

#include "content/ContentControl.hpp"
#include "graphics/ui/GUI.hpp"
#include "graphics/ui/elements/Menu.hpp"
#include "graphics/core/Batch2D.hpp"
#include "graphics/core/Shader.hpp"
#include "graphics/core/Texture.hpp"
#include "assets/Assets.hpp"
#include "maths/UVRegion.hpp"
#include "window/Window.hpp"
#include "window/Camera.hpp"
#include "engine/Engine.hpp"

MenuScreen::MenuScreen(Engine& engine) : Screen(engine) {
    engine.getContentControl().resetContent();
    
    auto menu = engine.getGUI().getMenu();
    menu->reset();
    menu->setPage("main");

    uicamera =
        std::make_unique<Camera>(glm::vec3(), engine.getWindow().getSize().y);
    uicamera->perspective = false;
    uicamera->near = -1.0f;
    uicamera->far = 1.0f;
    uicamera->flipped = true;
}

MenuScreen::~MenuScreen() = default;

void MenuScreen::update(float delta) {
    // Получаем позицию мыши
    const auto& cursor = engine.getInput().getCursor();
    mousePos = cursor.pos;
    
    // Вычисляем смещение на основе позиции мыши
    const auto& size = engine.getWindow().getSize();
    glm::vec2 center = glm::vec2(size) * 0.5f;
    glm::vec2 normalizedPos = (mousePos - center) / center;
    
    // Вычисляем целевое смещение для параллакса
    targetOffset = normalizedPos * PARALLAX_STRENGTH;
    
    // Плавно интерполируем текущее смещение к целевому
    currentOffset = glm::mix(currentOffset, targetOffset, SMOOTHING);
}

void MenuScreen::draw(float delta) {
    auto assets = engine.getAssets();

    display::clear();
    display::setBgColor(glm::vec3(0.2f));

    const auto& size = engine.getWindow().getSize();
    uint width = size.x;
    uint height = size.y;

    uicamera->setFov(height);
    uicamera->setAspectRatio(width / static_cast<float>(height));
    auto uishader = assets->get<Shader>("ui");
    uishader->use();
    uishader->uniformMatrix("u_projview", uicamera->getProjView());

    auto bg = assets->get<Texture>("gui/fon");
    batch->begin();
    batch->texture(bg);
    
    // Вычисляем масштаб для покрытия всего экрана без обрезки
    float scaleX = static_cast<float>(width) / bg->getWidth();
    float scaleY = static_cast<float>(height) / bg->getHeight();
    float scale = std::max(scaleX, scaleY); // Используем больший масштаб для покрытия
    
    // Увеличиваем масштаб для создания "приближения" и предотвращения повторения
    scale *= 1.1f; // Увеличиваем на 10% для показа скрытых частей
    
    // Вычисляем размер изображения после масштабирования
    float scaledWidth = bg->getWidth() * scale;
    float scaledHeight = bg->getHeight() * scale;
    
    // Вычисляем смещение для центрирования
    float offsetX = (scaledWidth - width) / 2.0f;
    float offsetY = (scaledHeight - height) / 2.0f;
    
    // Вычисляем UV координаты с учетом параллакса и центрирования
    float uStart = (offsetX + currentOffset.x * scaledWidth) / scaledWidth;
    float vStart = 1.0f - (offsetY + currentOffset.y * scaledHeight) / scaledHeight;
    float uEnd = (offsetX + width + currentOffset.x * scaledWidth) / scaledWidth;
    float vEnd = 1.0f - (offsetY + height + currentOffset.y * scaledHeight) / scaledHeight;
    
    batch->rect(
        0, 0, 
        width, height, 0, 0, 0, 
        UVRegion(uStart, vStart, uEnd, vEnd), 
        false, false, glm::vec4(1.0f)
    );
    batch->flush();
}
