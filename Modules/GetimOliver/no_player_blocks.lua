local no_player_blocks = {}

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128

local function player_only_block_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/no_player_block.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function activate(level_state)
    
    --todo: Fix

    define_tile_code("no_player_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_uid)
        ent:set_texture(player_only_block_texture())

        -- ent.color:set_rgba(0, 0, 0, 150) --Transparent

        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        -- ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
        -- ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)

        no_player_blocks[#no_player_blocks + 1] = get_entity(ent_uid)
        set_pre_collision2(ent_uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid then
                ent.flags = set_flag(ent.flags, ENT_FLAG.SOLID)
            else
                ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
            end
        end)
        return true
    end, "no_player_block")
end

local function deactivate()
    no_player_blocks = {}
    if #players < 1 then return end
    players[1].flags = set_flag(players[1].flags, ENT_FLAG.INTERACT_WITH_WEBS)
end

return {
    activate = activate,
    deactivate = deactivate
}
