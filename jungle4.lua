local checkpoints = require("Checkpoints/checkpoints")

local jungle4 = {
    identifier = "jungle4",
    title = "Jungle 4: Rockavator",
    theme = THEME.JUNGLE,
    width = 8,
    height = 1,
    file_name = "jung-4.lvl",
    world = 2,
    level = 4,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)
    
    
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "climbing_gloves")

    if not checkpoints.get_saved_checkpoint() then
        toast(jungle4.title)
    end
end

define_tile_code("slow_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:green()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then ent.velocityy = -.02 end
    end)
    return true
end, "slow_falling_platform")

define_tile_code("right_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:blue()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then
            ent.velocityy = 0.015 --keeps platform from falling
            -- ent.velocityx = 0.025
            ent.velocityx = 0.03
        end
    end)
    return true
end, "right_falling_platform")

jungle4.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle4
