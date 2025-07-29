-- Тестовый скрипт для проверки работы audio::play_sound_2d()

function test_audio()
    print("Тестируем audio::play_sound_2d()...")
    
    -- Пробуем воспроизвести звук
    local speaker = audio.play_sound_2d(
        "records/blocks",  -- имя загруженного звука
        0.7,  -- громкость
        1.0,  -- скорость
        "music",  -- канал
        false  -- не зацикливать
    )
    
    if speaker > 0 then
        print("✅ Звук успешно воспроизведен! Speaker ID: " .. speaker)
        return true
    else
        print("❌ Ошибка воспроизведения звука")
        return false
    end
end

-- Запускаем тест
test_audio() 