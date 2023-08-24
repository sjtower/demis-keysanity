local player_only_blocks = {}

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128

local function player_only_block_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/player_only_block.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function activate(level_state)
    
    --todo: use something other than webs

    define_tile_code("player_only_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_uid = spawn_entity(ENT_TYPE.ITEM_WEB, x, y, layer, 0, 0)
        local ent = get_entity(ent_uid)
        ent:set_texture(player_only_block_texture())

        ent.hitboxy = 1.0 --make tall, otherwise gaps appear
        -- ent.color:set_rgba(0, 0, 0, 150) --Transparent

        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)

        player_only_blocks[#player_only_blocks + 1] = get_entity(ent_uid)
        set_pre_collision2(ent_uid, function(self, collision_entity)
            players[1].flags = clr_flag(players[1].flags, ENT_FLAG.INTERACT_WITH_WEBS)
            if collision_entity.uid == players[1].uid then
                if players[1].holding_uid ~= -1 then
                    players[1]:get_held_entity():destroy()
                end
            end
            local flags = get_entity_flags(collision_entity.uid)
            if test_flag(flags, ENT_FLAG.USABLE_ITEM) or test_flag(flags, ENT_FLAG.PICKUPABLE) then
                if collision_entity.uid == players[1].uid then return end
                kill_entity(collision_entity.uid)
            end
        end)
        return true
    end, "player_only_block")
end

local function deactivate()
    player_only_blocks = {}
    if #players < 1 then return end
    players[1].flags = set_flag(players[1].flags, ENT_FLAG.INTERACT_WITH_WEBS)
end

return {
    activate = activate,
    deactivate = deactivate
}
