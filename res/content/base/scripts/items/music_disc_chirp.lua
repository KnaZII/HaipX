-- Пластинка: chirp
-- Использование: ПКМ для воспроизведения музыки, повторное нажатие останавливает

-- Переменные для управления музыкой
local current_speaker = nil
local is_playing = false

-- Функция для остановки текущей музыки
local function stop_music()
    if current_speaker then
        audio.stop(current_speaker)
        current_speaker = nil
        is_playing = false
    end
end

function on_use(player, item)
    -- Если уже играет, останавливаем и выходим
    if is_playing then
        player.send_message("§e⏹️ Музыка остановлена")
        stop_music()
        return true
    end
    
    -- Воспроизводим музыку
    current_speaker = audio.play_stream_2d(
        "sounds/records/chirp.ogg",  -- полный путь к файлу
        0.7,  -- громкость
        1.0,  -- скорость
        "music",  -- канал
        false  -- не зацикливать
    )
    
    if current_speaker > 0 then
        is_playing = true
        player.send_message("§a♫ Воспроизводится пластинка: chirp")
        return true
    else
        player.send_message("§c❌ Ошибка воспроизведения музыки")
        return false
    end
end
