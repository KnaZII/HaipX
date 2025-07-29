-- Survival HUD Script
-- Обновляет отображение здоровья и голода

local health_bar = nil
local hunger_bar = nil

function on_hud_open()
    -- Получаем элементы HUD
    health_bar = hud.get_element("health_bar")
    hunger_bar = hud.get_element("hunger_bar")
    
    -- Обновляем HUD каждые 0.1 секунды
    timer.schedule(0.1, update_survival_hud, true)
end

function update_survival_hud()
    local player_id = hud.get_player()
    if not player_id then
        return
    end
    
    -- Получаем данные игрока
    local health = player.get_health(player_id)
    local max_health = player.get_max_health(player_id)
    local hunger = player.get_hunger(player_id)
    local max_hunger = player.get_max_hunger(player_id)
    
    -- Обновляем полоску здоровья
    if health_bar then
        local health_percent = health / max_health
        health_bar:set_size(45 * health_percent, 15)
        
        -- Меняем цвет в зависимости от здоровья
        if health_percent > 0.6 then
            health_bar:set_color(0, 1, 0, 1) -- Зеленый
        elseif health_percent > 0.3 then
            health_bar:set_color(1, 1, 0, 1) -- Желтый
        else
            health_bar:set_color(1, 0, 0, 1) -- Красный
        end
    end
    
    -- Обновляем полоску голода
    if hunger_bar then
        local hunger_percent = hunger / max_hunger
        hunger_bar:set_size(45 * hunger_percent, 15)
        
        -- Меняем цвет в зависимости от голода
        if hunger_percent > 0.6 then
            hunger_bar:set_color(0.545, 0.271, 0.075, 1) -- Коричневый
        elseif hunger_percent > 0.3 then
            hunger_bar:set_color(1, 0.5, 0, 1) -- Оранжевый
        else
            hunger_bar:set_color(1, 0, 0, 1) -- Красный
        end
    end
end 