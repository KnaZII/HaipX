#pragma once

#include "Screen.hpp"
#include <glm/glm.hpp>

#include <memory>

class Camera;
class Engine;

class MenuScreen : public Screen {
    std::unique_ptr<Camera> uicamera;
    
    // Переменные для эффекта параллакса
    glm::vec2 mousePos = {0.0f, 0.0f};
    glm::vec2 targetOffset = {0.0f, 0.0f};
    glm::vec2 currentOffset = {0.0f, 0.0f};
    static constexpr float PARALLAX_STRENGTH = 0.02f; // Сила эффекта
    static constexpr float SMOOTHING = 0.1f; // Плавность движения
    
public:
    MenuScreen(Engine& engine);
    ~MenuScreen();

    void update(float delta) override;
    void draw(float delta) override;
};
