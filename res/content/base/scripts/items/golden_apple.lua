-- Золотое яблоко
-- Восстанавливает здоровье и голод

function on_use(player, item)
    local health = player.get_health()
    local max_health = player.get_max_health()
    local hunger = player.get_hunger()
    local max_hunger = player.get_max_hunger()
    
    local used = false
    
    -- Восстанавливаем здоровье
    if health < max_health then
        player.set_health(math.min(health + 4, max_health))
        used = true
    end
    
    -- Восстанавливаем голод
    if hunger < max_hunger then
        player.set_hunger(math.min(hunger + 9, max_hunger))
        used = true
    end
    
    if used then
        -- Уменьшаем количество предметов в стаке
        item.set_count(item.get_count() - 1)
        return true
    end
    
    return false
end 