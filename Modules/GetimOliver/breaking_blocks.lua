local right_blocks = {}
local left_blocks = {}

local function activate(level_state)
    
    define_tile_code("breaking_block_right")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local block_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local block = get_entity(block_uid)
        block.flags = set_flag(block.flags, ENT_FLAG.NO_GRAVITY)
        block.more_flags = set_flag(block.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
        right_blocks[#right_blocks + 1] = get_entity(block_uid)
        return true
    end, "breaking_block_right")

    define_tile_code("breaking_block_left")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local block_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local block = get_entity(block_uid)
        block.flags = set_flag(block.flags, ENT_FLAG.NO_GRAVITY)
        block.more_flags = set_flag(block.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
        left_blocks[#left_blocks + 1] = get_entity(block_uid)
        return true
    end, "breaking_block_left")

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function() 
        if #players < 1 then return end

        local x, y, l = get_position(players[1].uid)


        for i, block in ipairs(right_blocks) do
            if x > block.x + 0.25 and players[1].standing_on_uid == right_blocks[i].uid then
                kill_entity(block.uid)
                local sound = get_sound(VANILLA_SOUND.SHARED_TILE_BREAK)
                sound:play()
            end
        end

        for i, block in ipairs(left_blocks) do
            if x + 0.25 < block.x and players[1].standing_on_uid == left_blocks[i].uid then
                kill_entity(block.uid)
                local sound = get_sound(VANILLA_SOUND.SHARED_TILE_BREAK)
                sound:play()
            end
        end

    end, ON.FRAME)
end

local function deactivate()
    left_blocks = {}
    right_blocks = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
