-- Деревянная лопата
-- Увеличивает скорость добычи земли и песка

function on_block_break_by(player, item, x, y, z)
    local block = world.get_block(x, y, z)
    local block_name = block.name
    
    -- Проверяем, является ли блок землей или песком
    if block_name == "base:dirt" or 
       block_name == "base:sand" or
       block_name == "base:grass" or
       block_name == "base:grass_block" then
        -- Увеличиваем скорость добычи земли
        return true
    end
    
    return false
end 