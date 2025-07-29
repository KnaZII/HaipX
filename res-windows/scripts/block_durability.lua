-- Block durability system
-- Определяет время разрушения для разных типов блоков

local block_durability = {
    -- Мгновенное разрушение (0.0)
    ["grass"] = 0.0,
    ["flower"] = 0.0,
    ["torch"] = 0.0,
    
    -- Быстрое разрушение (1.5 сек)
    ["dirt"] = 1.5,
    ["sand"] = 1.5,
    ["leaves"] = 1.5,
    
    -- Среднее разрушение (3.0 сек)
    ["wood"] = 3.0,
    ["planks"] = 3.0,
    ["brick"] = 3.0,
    ["glass"] = 3.0,
    ["ice"] = 3.0,
    
    -- Медленное разрушение (5.0+ сек)
    ["stone"] = 8.0,
    ["metal"] = 10.0,
    ["bazalt"] = 12.0,
}

function block.get_durability(block_name)
    return block_durability[block_name] or 3.0
end

-- Инструменты и их множители скорости
local tool_multipliers = {
    -- Рука (множитель 1.0)
    ["hand"] = 1.0,
    
    -- Лопата для земли, песка
    ["shovel"] = {
        ["dirt"] = 2.0,
        ["sand"] = 2.0,
        ["grass"] = 2.0,
    },
    
    -- Топор для дерева
    ["axe"] = {
        ["wood"] = 2.0,
        ["planks"] = 2.0,
        ["leaves"] = 2.0,
    },
    
    -- Кирка для камня
    ["pickaxe"] = {
        ["stone"] = 2.0,
        ["bazalt"] = 2.0,
        ["metal"] = 2.0,
        ["brick"] = 2.0,
    },
}

function block.get_tool_multiplier(tool_type, block_name)
    if not tool_type or tool_type == "hand" then
        return 1.0
    end
    
    local tool = tool_multipliers[tool_type]
    if not tool then
        return 1.0
    end
    
    if type(tool) == "number" then
        return tool
    end
    
    return tool[block_name] or 1.0
end

-- Функция для получения времени разрушения с учетом инструмента
function block.get_breaking_time(block_name, tool_type)
    local durability = block.get_durability(block_name)
    local multiplier = block.get_tool_multiplier(tool_type, block_name)
    
    if durability <= 0.0 then
        return 0.0
    end
    
    return durability / multiplier
end 