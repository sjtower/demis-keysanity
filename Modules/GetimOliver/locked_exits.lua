local locked_exits = {}
local exit_keys = {}
local key_blocks = {}

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128
local function locked_door_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/locked_door_1.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end


local function activate(level_state)
    
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
        -- key_block.color = Color:yellow()
        -- key_block.flags = set_flag(key_block.flags, ENT_FLAG.NO_GRAVITY)
        key_block.more_flags = set_flag(key_block.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
        key_block.flags = set_flag(key_block.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        key_block.flags = clr_flag(key_block.flags, ENT_FLAG.SOLID)
        key_block:set_texture(locked_door_texture())

        lock_door_at(x, y)

        key_blocks[#key_blocks + 1] = get_entity(key_block_uid)

        return true
    end, "locked_exit")

    define_tile_code("exit_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:white()
        exit_keys[#exit_keys + 1] = get_entity(uid)
        set_pre_collision2(key.uid, function(self, collision_entity)
            for _, exit_key_block in ipairs(key_blocks) do
                if collision_entity.uid == exit_key_block.uid then
                    -- kill_entity(door_uid)
                    kill_entity(exit_key_block.uid)
                    kill_entity(key.uid)
                    unlock_door_at(exit_key_block.x, exit_key_block.y)
                    local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
                    sound:play()
                end
            end
        end)
        return true
    end, "exit_key")
end

local function deactivate()
    locked_exits = {}
    exit_keys = {}
    key_blocks = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
