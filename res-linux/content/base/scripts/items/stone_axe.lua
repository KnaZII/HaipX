-- Каменный топор
-- Увеличивает скорость добычи дерева (лучше деревянного)

function on_block_break_by(player, item, x, y, z)
    local block = world.get_block(x, y, z)
    local block_name = block.name
    
    -- Проверяем, является ли блок деревом
    if block_name == "base:wood" or 
       block_name == "base:leaves" or
       block_name == "base:planks" then
        -- Увеличиваем скорость добычи дерева (больше чем деревянный)
        return true
    end
    
    return false
end 