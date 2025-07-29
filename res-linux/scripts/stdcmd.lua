local SEPARATOR = "________________"
SEPARATOR = SEPARATOR .. SEPARATOR .. SEPARATOR

function build_scheme(command)
    local str = command.name .. " "
    for i,arg in ipairs(command.args) do
        if arg.optional then
            str = str .. "[" .. arg.name .. "] "
        else
            str = str .. "<" .. arg.name .. "> "
        end
    end
    return str
end

console.add_command(
    "clear",
    "Clears the console",
    function()
        local document = Document.new("core:console")
        document.log.text = ""
    end
)

console.add_command(
    "help name:str=''",
    "Show help infomation for the specified command",
    function(args, kwargs)
        local name = args[1]
        if #name == 0 then
            local str = "=== Доступные команды ==="
            str = str .. "\nhelp - показать эту справку"
            str = str .. "\nsurvival - переключиться в режим выживания"
            str = str .. "\ncreative - переключиться в креативный режим"
            str = str .. "\ngamemode 0 - режим выживания"
            str = str .. "\ngamemode 1 - креативный режим"
            str = str .. "\ntp <x> <y> <z> - телепортация"
            str = str .. "\ngive <item> <count> - дать предмет"
            str = str .. "\ntime <day/night> - установить время"
            str = str .. "\nweather <clear/rain/snow> - установить погоду"
            str = str .. "\n========================"
            return str
        end

        local command = console.get_command_info(name)

        if command == nil then
            return string.format("command %q not found", name)
        end

        local where = ":"
        local str = SEPARATOR .. "\n" .. command.description .. "\n" .. name .. " "

        for _, arg in ipairs(command.args) do
            where = where .. "\n  " .. arg.name .. " - " .. arg.type

            if arg.optional then
                str = str .. "[" .. arg.name .. "] "
                where = where .. " (optional)"
            else
                str = str .. "<" .. arg.name .. "> "
            end
        end

        if #command.args > 0 then
            str = str .. "\nwhere" .. where
        end

        return str .. "\n" .. SEPARATOR
    end
)

console.add_command(
    "time.uptime",
    "Get time elapsed since the engine started",
    function()
        local uptime = time.uptime()
        local formatted_uptime = ""

        local t = string.formatted_time(uptime)

        formatted_uptime = t.h .. "h " .. t.m .. "m " .. t.s .. "s"

        return formatted_uptime .. " (" .. uptime .. "s)"
    end
)

console.add_command(
    "tp entity:sel=$entity.id x:num~pos.x y:num~pos.y z:num~pos.z",
    "Teleport entity",
    function(args, kwargs)
        local eid, x, y, z = unpack(args)
        local entity = entities.get(eid)
        if entity then
            entity.transform:set_pos({x, y, z})
        end
    end
)
console.add_command(
    "echo value:str",
    "Print value to the console",
    function(args, kwargs)
        return args[1]
    end
)

console.add_command(
    "survival",
    "Переключиться в режим выживания",
    function(args, kwargs)
        local pid = hud.get_player()
        if pid then
            player.set_survival_mode(pid, true)
            player.set_flight(pid, false)
            player.set_noclip(pid, false)
            player.set_infinite_items(pid, false)
            player.set_instant_destruction(pid, false)
            return "Режим выживания включен"
        end
        return "Игрок не найден"
    end
)

console.add_command(
    "creative",
    "Переключиться в креативный режим",
    function(args, kwargs)
        local pid = hud.get_player()
        if pid then
            player.set_survival_mode(pid, false)
            player.set_flight(pid, true)
            player.set_noclip(pid, false)
            player.set_infinite_items(pid, true)
            player.set_instant_destruction(pid, true)
            return "Креативный режим включен"
        end
        return "Игрок не найден"
    end
)

console.add_command(
    "gamemode mode:str",
    "Установить режим игры (0=survival, 1=creative)",
    function(args, kwargs)
        local mode = args[1]
        local pid = hud.get_player()
        if not pid then
            return "Игрок не найден"
        end
        
        if mode == "0" or mode == "survival" then
            player.set_survival_mode(pid, true)
            player.set_flight(pid, false)
            player.set_noclip(pid, false)
            player.set_infinite_items(pid, false)
            player.set_instant_destruction(pid, false)
            return "Режим выживания включен"
        elseif mode == "1" or mode == "creative" then
            player.set_survival_mode(pid, false)
            player.set_flight(pid, true)
            player.set_noclip(pid, false)
            player.set_infinite_items(pid, true)
            player.set_instant_destruction(pid, true)
            return "Креативный режим включен"
        else
            return "Неизвестный режим. Используйте 0/survival или 1/creative"
        end
    end
)
console.add_command(
    "time.set value:num",
    "Set day time [0..1] where 0 is midnight, 0.5 is noon",
    function(args, kwargs)
        world.set_day_time(args[1])
        return "Time set to " .. args[1]
    end
)

console.add_command(
    "time.daycycle operation:[stop|reset]",
    "Control time.daycycle. Operations: stop, reset",
    function(args, kwargs)
        local operation = args[1]
        if operation == "stop" then
            world.set_day_time_speed(0)
            return "Daily cycle has stopped"
        else
            world.set_day_time_speed(1.0)
            return "Daily cycle has started"
        end
    end
)

console.add_command(
    "blocks.fill id:str x1:int~pos.x y1:int~pos.y z1:int~pos.z "..
                       "x2:int~pos.x y2:int~pos.y z2:int~pos.z",
    "Fill specified zone with blocks",
    function(args, kwargs)
        local name, x1,y1,z1, x2,y2,z2 = unpack(args)
        local id = block.index(name)
        for y=y1,y2 do
            for z=z1,z2 do
                for x=x1,x2 do
                    block.set(x, y, z, id)
                end
            end
        end
        local w = math.floor(math.abs(x2-x1+1) + 0.5)
        local h = math.floor(math.abs(y2-y1+1) + 0.5)
        local d = math.floor(math.abs(z2-z1+1) + 0.5)
        return tostring(w * h * d) .. " blocks set"
    end
)

console.add_command(
    "player.respawn player:sel=$obj.id",
    "Respawn player entity",
    function(args, kwargs)
        local eid = entities.spawn("base:player", {player.get_pos(args[1])}):get_uid()
        player.set_entity(args[1], eid)
        return "spawned new player entity #" .. tostring(eid)
    end
)

console.add_command(
    "entity.despawn entity:sel=$entity.selected",
    "Despawn entity",
    function(args, kwargs)
        local eid = args[1]
        local entity = entities.get(eid)
        if entity ~= nil then
            entity:despawn()
            return "despawned entity #" .. tostring(eid)
        end
    end
)

console.add_command(
    "fragment.save x1:int~pos.x y1:int~pos.y z1:int~pos.z "..
                  "x2:int~pos.x y2:int~pos.y z2:int~pos.z "..
                  "name:str='untitled' crop:bool=false",
    "Save fragment",
    function(args, kwargs)
        local x1 = args[1]
        local y1 = args[2]
        local z1 = args[3]

        local x2 = args[4]
        local y2 = args[5]
        local z2 = args[6]

        local name = args[7]
        local crop = args[8]
        
        local fragment = generation.create_fragment(
            {x1, y1, z1}, {x2, y2, z2}, crop, false
        )
        local filename = 'export:'..name..'.vox'
        generation.save_fragment(fragment, filename, crop)
        console.log("fragment with size "..vec3.tostring(fragment.size)..
                    " has been saved as "..file.resolve(filename))
    end
)

console.add_command(
    "fragment.crop file:str",
    "Crop fragment",
    function(args, kwargs)
        local filename = args[1]
        local fragment = generation.load_fragment(filename)
        fragment:crop()
        generation.save_fragment(fragment, filename, crop)
        console.log("fragment with size "..vec3.tostring(fragment.size)..
                    " has been saved as "..file.resolve(filename))
    end
)

console.add_command(
    "fragment.place file:str x:num~pos.x y:num~pos.y z:num~pos.z rotation:int=0",
    "Place fragment to the world",
    function(args, kwargs)
        local filename = args[1]
        local x = args[2]
        local y = args[3]
        local z = args[4]
        local rotation = args[5]
        local fragment = generation.load_fragment(filename)
        fragment:place({x, y, z}, rotation)
    end
)

console.add_command(
    "rule.set name:str value:bool",
    "Set rule value",
    function(args, kwargs)
        local name = args[1]
        local value = args[2]
        rules.set(name, value)
        return "rule '"..name.."' set to "..tostring(value)
    end
)

console.add_command(
    "rule.list",
    "Show registered rules list",
    function(args, kwargs)
        local names = ""
        for name, rule in pairs(rules.rules) do
            if #names > 0 then
                names = names .. "\n  "
            else
                names = "  "
            end
            local value = rule.value
            if value == nil then
                value = "not set"
            end
            names = names .. name .. ":\t" .. tostring(value)
        end
        return "registered rules:\n" .. names
    end
)

console.add_command(
    "chat text:str",
    "Send chat message",
    function (args, kwargs)
        console.chat("[you] "..args[1])
    end
)

console.add_command(
    "weather.set name:str time:num=1",
    "Change weather",
    function (args, kwargs)
        local filename = file.find("presets/weather/"..args[1]..".json")
        if not filename then
            return "weather preset not found"
        end
        local preset = json.parse(file.read(filename))
        gfx.weather.change(preset, args[2], args[1])
        return "weather set to "..filename.." preset ("..tostring(args[2]).." s)"
    end
)

console.add_command(
    "weather",
    "Display current weather preset name",
    function (args, kwargs)
        local name = gfx.weather.get_current()
        if name == "" then
            return "unnamed " .. json.tostring(gfx.weather.get_current_data(), true)
        else
            return name
        end
    end
)

console.add_command(
    "weather.list",
    "Show available weather presets list",
    function(args, kwargs)
        local filenames = file.list_all_res("presets/weather/")
        local presets = " "
        for index, filename in pairs(filenames) do
            presets = presets .. "\n" .. file.stem(filename)
        end
        return "available presets:" .. presets
    end
)

console.cheats = {
    "blocks.fill",
    "tp",
    "fragment.place",
    "time.set",
    "time.daycycle",
    "entity.despawn",
    "player.respawn",
    "weather.set",
}
