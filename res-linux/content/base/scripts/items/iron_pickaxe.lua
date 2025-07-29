-- Железная кирка
-- Увеличивает скорость добычи камня и руд (лучше каменной)

function on_block_break_by(player, item, x, y, z)
    local block = world.get_block(x, y, z)
    local block_name = block.name
    
    -- Проверяем, является ли блок камнем или рудой
    if block_name == "base:stone" or 
       block_name == "base:coal_ore" or
       block_name == "base:bazalt" then
        -- Увеличиваем скорость добычи (больше чем каменная)
        return true
    end
    
    return false
end 