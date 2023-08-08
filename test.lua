local nocrap = require("Modules.Dregu.no_crap")
local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")
local telescopes = require("Telescopes/telescopes")

local dwelling1 = {
    identifier = "test",
    title = "Test",
    theme = THEME.DWELLING,
    width = 2,
    height = 2,
    file_name = "test.lvl",
    world = 1,
    level = 1,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    -- fix camera to center of stage (2x2 only)
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function() 
        if #players < 1 then return end

        state.camera.adjusted_focus_x = 12.5
        state.camera.adjusted_focus_y = 114.5

    end, ON.FRAME)

    local locked_exits = {}
    local exit_keys = {}
    local key_blocks = {}

    -- try: set custom texture for exit key block

    define_tile_code("locked_exit")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local exit_uid = spawn_entity(ENT_TYPE.BG_DOOR, x, y, layer, 0, 0)
        local door_uid = spawn_door(x, y, layer, state.world, state.level, state.theme)
        
        local exit = get_entity(exit_uid)
        -- todo: get texture basewd on theme
        exit:set_texture(TEXTURE.DATA_TEXTURES_FLOOR_CAVE_2)
        exit.animation_frame = set_flag(exit.animation_frame, 1)
        locked_exits[#locked_exits+1] = exit

        local key_block_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local key_block = get_entity(key_block_uid)
        key_block.color = Color:yellow()
        -- key_block.flags = set_flag(key_block.flags, ENT_FLAG.NO_GRAVITY)
        key_block.more_flags = set_flag(key_block.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
        key_blocks[#key_blocks + 1] = get_entity(key_block_uid)

        return true
    end, "locked_exit")


    define_tile_code("exit_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:red()
        exit_keys[#exit_keys + 1] = get_entity(uid)
        set_pre_collision2(key.uid, function(self, collision_entity)
            for _, exit_key_block in ipairs(key_blocks) do
                if collision_entity.uid == exit_key_block.uid then
                    -- kill_entity(door_uid)
                    kill_entity(exit_key_block.uid)
                    kill_entity(key.uid)
                    local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
                    sound:play()
                end
            end
        end)
        return true
    end, "exit_key")

    signs.activate(level_state, {"Pro Tip: Hit the snake at the bottom of its bounce and hold right"})
    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling1.title)
    end
    

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
