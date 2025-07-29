local _, dir = parse_path(__DIR__)
local ores = require "base:generation/ores"
math.randomseed(SEED)
ores.load(dir)

local function get_rand(seed, x, y, z)
    local h = bit.bxor(bit.bor(x * 23729, y % 16786), y * x + seed)
    h = bit.bxor(h, z * 47917)
    h = bit.bxor(h, bit.bor(z % 12345, x + y))

    local n = (h % 10000) / 10000.0

    return n
end

local function gen_parameters(size, seed, x, y)
    local res = {}
    local rand = 0

    for i=1, size do
        rand = get_rand(seed, x, y, rand)
        table.insert(res, rand)
    end

    return res
end

function place_structures(x, z, w, d, hmap, chunk_height)
    local placements = {}
    ores.place(placements, x, z, w, d, SEED, hmap, chunk_height)
    return placements
end

function place_structures_wide(x, z, w, d, chunk_height)
    local placements = {}
    local rands = gen_parameters(11, SEED, x, z)
    
    -- Генерируем пещеры в горах
    if rands[1] < 0.08 then
        local sx = x + rands[2] * 10 - 5
        local sy = rands[3] * (chunk_height / 3) + 20
        local sz = z + rands[4] * 10 - 5

        local dir = rands[5] * math.pi * 2
        local dir_inertia = (rands[6] - 0.5) * 2
        local elevation = -2
        local width = rands[7] * 4 + 3

        for i=1,25 do
            local dx = math.sin(dir) * 12
            local dz = -math.cos(dir) * 12

            local ex = sx + dx
            local ey = sy + elevation
            local ez = sz + dz

            table.insert(placements, 
                {":line", 0, {sx, sy, sz}, {ex, ey, ez}, width})

            sx = ex
            sy = ey
            sz = ez

            dir_inertia = dir_inertia * 0.8 + 
                (rands[8] - 0.5) * math.pow(rands[9], 2) * 6
            elevation = elevation * 0.9 + 
                (rands[10] - 0.4) * (1.0-math.pow(rands[11], 4)) * 6
            dir = dir + dir_inertia
        end
    end
    
    return placements
end

function generate_heightmap(x, y, w, h, s, inputs)
    -- Основная карта высот для гор - УСИЛЕННАЯ ВЕРСИЯ
    local base_map = Heightmap(w, h)
    base_map.noiseSeed = SEED
    
    -- Создаем базовый шум для горных хребтов - БОЛЬШЕ АМПЛИТУДА
    base_map:noise({x, y}, 0.03*s, 8, 0.01) -- Более крупные горы
    base_map:mul(4.0) -- Увеличиваем амплитуду в 2 раза
    base_map:add(0.1) -- Ниже базовая высота
    
    -- Добавляем детализированный шум для горных пиков
    local detail_map = Heightmap(w, h)
    detail_map.noiseSeed = SEED + 1234
    detail_map:noise({x+100, y+200}, 0.15*s, 5, 0.08)
    detail_map:mul(0.7)
    detail_map:add(0.3)
    detail_map:pow(3.0) -- Делаем пики еще более острыми
    
    -- Комбинируем базовую карту с деталями
    base_map:mul(detail_map)
    
    -- Создаем карту для долин и рек - БОЛЕЕ ГЛУБОКИЕ
    local valley_map = Heightmap(w, h)
    valley_map.noiseSeed = SEED + 5678
    valley_map:noise({x+300, y+400}, 0.12*s, 6, 0.04)
    valley_map:abs()
    valley_map:mul(5.0) -- Увеличиваем глубину долин
    valley_map:pow(0.15) -- Делаем долины еще более глубокими
    valley_map:max(0.05) -- Минимальная высота долин
    
    -- Создаем карту рек - БОЛЕЕ ГЛУБОКИЕ
    local river_map = Heightmap(w, h)
    river_map.noiseSeed = SEED + 9999
    river_map:noise({x+500, y+600}, 0.06*s, 7, 0.02)
    river_map:abs()
    river_map:mul(6.0) -- Увеличиваем глубину рек
    river_map:pow(0.08) -- Очень глубокие реки
    river_map:max(0.03) -- Минимальная высота рек
    
    -- Комбинируем все карты
    local final_map = Heightmap(w, h)
    final_map.noiseSeed = SEED
    
    -- Основная высота гор
    final_map:copy(base_map)
    
    -- Добавляем долины
    final_map:mul(valley_map)
    
    -- Добавляем реки
    final_map:mul(river_map)
    
    -- Создаем карту температуры для выбора биомов
    local temp_map = Heightmap(w, h)
    temp_map.noiseSeed = SEED + 1111
    temp_map:noise({x+700, y+800}, 0.1*s, 4, 0.02)
    temp_map:mul(0.5)
    temp_map:add(0.5)
    
    -- Применяем температурную карту к высоте (высокие горы холоднее)
    final_map:mixin(temp_map, inputs[1])
    
    -- Финальная настройка высоты - УСИЛЕННАЯ
    final_map:mul(3.0) -- Увеличиваем общую высоту в 2 раза
    final_map:add(0.1) -- Ниже минимальная высота
    
    return final_map
end

function generate_biome_parameters(x, y, w, h, s)
    -- Карта температуры - зависит от высоты
    local tempmap = Heightmap(w, h)
    tempmap.noiseSeed = SEED + 5324
    tempmap:noise({x, y}, 0.08*s, 6)
    tempmap:mul(0.3) -- Меньше вариаций температуры
    tempmap:add(0.5)
    
    -- Карта влажности - больше вариаций для гор
    local hummap = Heightmap(w, h)
    hummap.noiseSeed = SEED + 953
    hummap:noise({x, y}, 0.12*s, 5)
    hummap:mul(0.7) -- Больше вариаций влажности
    hummap:add(0.3)
    
    -- Делаем распределение более резким для четкого разделения биомов
    tempmap:pow(2)
    hummap:pow(1.5)
    
    return tempmap, hummap
end 