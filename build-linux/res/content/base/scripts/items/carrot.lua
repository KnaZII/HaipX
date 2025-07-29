-- Морковь
-- Восстанавливает голод

function on_use(player, item)
    local hunger = player.get_hunger()
    local max_hunger = player.get_max_hunger()
    
    if hunger < max_hunger then
        player.set_hunger(math.min(hunger + 3, max_hunger))
        -- Уменьшаем количество предметов в стаке
        item.set_count(item.get_count() - 1)
        return true
    end
    
    return false
end 