-- Minecraft-style HUD Script
-- Отображает сердечки и голод как в Minecraft

local health_container = nil
local hunger_container = nil
local command_container = nil
local command_text = nil
local hearts = {}
local food_icons = {}

function on_hud_open()
    -- Получаем элементы HUD
    health_container = hud.get_element("health_container")
    hunger_container = hud.get_element("hunger_container")
    command_container = hud.get_element("command_container")
    command_text = hud.get_element("command_text")
    
    -- Создаем сердечки
    create_hearts()
    
    -- Создаем иконки голода
    create_food_icons()
    
    -- Обновляем HUD каждые 0.1 секунды
    timer.schedule(0.1, update_minecraft_hud, true)
end

function create_hearts()
    -- Создаем 10 сердечек (20 здоровья / 2 = 10 сердечек)
    for i = 1, 10 do
        local heart = hud.create_image("gui/hud/container", 16, 16)
        heart:set_pos((i-1) * 18, 0)
        heart:set_id("heart_" .. i)
        health_container:add(heart)
        table.insert(hearts, heart)
    end
end

function create_food_icons()
    -- Создаем 10 иконок голода (20 голода / 2 = 10 иконок)
    for i = 1, 10 do
        local food = hud.create_image("gui/hud/food_empty", 16, 16)
        food:set_pos((i-1) * 18, 0)
        food:set_id("food_" .. i)
        hunger_container:add(food)
        table.insert(food_icons, food)
    end
end

function update_minecraft_hud()
    local player_id = hud.get_player()
    if not player_id then
        return
    end
    
    -- Получаем данные игрока
    local health = player.get_health(player_id)
    local max_health = player.get_max_health(player_id)
    local hunger = player.get_hunger(player_id)
    local max_hunger = player.get_max_hunger(player_id)
    local survival_mode = player.is_survival_mode(player_id)
    
    -- Обновляем сердечки только в режиме выживания
    if survival_mode then
        health_container:set_visible(true)
        hunger_container:set_visible(true)
        update_hearts(health, max_health)
        update_food_icons(hunger, max_hunger)
    else
        -- В креативном режиме скрываем HUD
        health_container:set_visible(false)
        hunger_container:set_visible(false)
    end
    
    -- Обновляем командную строку
    local command_mode = player.is_command_mode(player_id)
    if command_mode then
        show_command_input(player.get_command_buffer(player_id))
    else
        hide_command_input()
    end
end

function update_hearts(health, max_health)
    local full_hearts = math.floor(health / 2)
    local half_heart = health % 2 == 1
    
    for i = 1, #hearts do
        local heart = hearts[i]
        if i <= full_hearts then
            -- Полное сердечко
            heart:set_texture("gui/hud/full")
        elseif i == full_hearts + 1 and half_heart then
            -- Половина сердечка
            heart:set_texture("gui/hud/half")
        else
            -- Пустое сердечко
            heart:set_texture("gui/hud/container")
        end
    end
end

function update_food_icons(hunger, max_hunger)
    local full_food = math.floor(hunger / 2)
    local half_food = hunger % 2 == 1
    
    for i = 1, #food_icons do
        local food = food_icons[i]
        if i <= full_food then
            -- Полная иконка еды
            food:set_texture("gui/hud/food_full")
        elseif i == full_food + 1 and half_food then
            -- Половина иконки еды
            food:set_texture("gui/hud/food_half")
        else
            -- Пустая иконка еды
            food:set_texture("gui/hud/food_empty")
        end
    end
end

-- Функция для показа командной строки
function show_command_input(text)
    if command_container and command_text then
        command_container:set_visible(true)
        command_text:set_text(text or "")
    end
end

-- Функция для скрытия командной строки
function hide_command_input()
    if command_container then
        command_container:set_visible(false)
    end
end 