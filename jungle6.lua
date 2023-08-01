local signs = require("Modules.JayTheBusinessGoose.signs")
local jungle6 = {
    identifier = "jungle6",
    title = "Jungle 6: Chief Ooga",
    theme = THEME.JUNGLE,
    width = 3,
    height = 2,
    file_name = "jung-6.lvl",
    world = 2,
    level = 6,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    signs.activate(level_state, {"Kill Chief Ooga!"})

    define_tile_code("witch_doctor_chief")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.MONS_WITCHDOCTOR, x, y, layer, 0, 0)
        local ent = get_entity(uid)
        ent.health = 8
        ent.color:set_rgba(108, 220, 235, 255) --light blue
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)

        set_on_kill(uid, function(self)
            local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        end)

        return true
    end, "witch_doctor_chief")

    toast(jungle6.title)
end

define_tile_code("fast_right_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:yellow()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then
            ent.velocityy = 0.015 --keeps platform from falling
            -- ent.velocityx = 0.027
            ent.velocityx = 0.075
        end
    end)
    return true
end, "fast_right_falling_platform")

define_tile_code("fast_left_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:purple()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then
            ent.velocityy = 0.015 --keeps platform from falling
            -- ent.velocityx = 0.027
            ent.velocityx = -0.075
        end
    end)
    return true
end, "fast_left_falling_platform")

jungle6.unload_level = function()
    if not level_state.loaded then return end

    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle6
