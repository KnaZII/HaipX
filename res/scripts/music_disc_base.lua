-- Базовый скрипт для музыкальных пластинок
-- Этот скрипт содержит общую логику для всех пластинок

local current_music_speaker = nil
local current_music_item = nil

-- Функция для остановки текущей музыки
local function stop_current_music()
    if current_music_speaker then
        audio.stop(current_music_speaker)
        current_music_speaker = nil
        current_music_item = nil
    end
end

-- Функция для воспроизведения музыки пластинки
function play_music_disc(item_name, sound_file)
    local player = player.get_current()
    if not player then
        return false
    end
    
    -- Останавливаем предыдущую музыку
    stop_current_music()
    
    -- Воспроизводим новую музыку
    current_music_speaker = audio.play_stream_2d(
        sound_file,
        0.7,  -- громкость
        1.0,  -- скорость
        "music",  -- канал
        false  -- не зацикливать
    )
    
    if current_music_speaker > 0 then
        current_music_item = item_name
        return true
    end
    
    return false
end

-- Функция для использования пластинки (ПКМ)
function on_use(player, item)
    local item_name = item.get_name()
    local sound_file = "sounds/records/" .. item_name:gsub("base:music_disc_", "") .. ".ogg"
    
    if play_music_disc(item_name, sound_file) then
        -- Показываем сообщение игроку
        player.send_message("§a♫ Воспроизводится: " .. item.get_caption())
        return true
    else
        player.send_message("§c❌ Ошибка воспроизведения музыки")
        return false
    end
end

-- Функция для остановки музыки (можно вызвать из других скриптов)
function stop_music()
    stop_current_music()
end

-- Экспортируем функции для использования в других скриптах
return {
    play_music_disc = play_music_disc,
    stop_music = stop_music,
    on_use = on_use
} 