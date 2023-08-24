local up_blocks = {}
local down_blocks = {}

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128

local function one_way_up_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/one_way_up.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function one_way_down_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/one_way_down.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function activate(level_state)

    define_tile_code("one_way_up")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local platform_uid = spawn_entity(ENT_TYPE.FLOOR_PLATFORM, x, y, layer, 0, 0)
        local block_uid = spawn_entity(ENT_TYPE.ITEM_WEB, x, y, layer, 0, 0)
        local block = get_entity(block_uid)
        
        block.flags = set_flag(block.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        block.flags = clr_flag(block.flags, ENT_FLAG.SOLID)
        
        block.hitboxy = 0.45
        block.hitboxx = 0.5

        block:set_texture(one_way_up_texture())

        up_blocks[#up_blocks + 1] = get_entity(block_uid)
        set_pre_collision2(block_uid, function(self, collidee)
            if collidee.velocityy < 0.1 then collidee.velocityy = 0.1 end
            return true
        end)
        return true
    end, "one_way_up")

    define_tile_code("one_way_down")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local platform_uid = spawn_entity(ENT_TYPE.FLOOR_PLATFORM, x, y, layer, 0, 0)
        local block_uid = spawn_entity(ENT_TYPE.ITEM_WEB, x, y, layer, 0, 0)
        local block = get_entity(block_uid)
        
        block.flags = set_flag(block.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        block.flags = clr_flag(block.flags, ENT_FLAG.SOLID)

        block.hitboxy = 0.45
        block.hitboxx = 0.5
        
        block:set_texture(one_way_down_texture())

        down_blocks[#down_blocks + 1] = get_entity(block_uid)
        set_pre_collision2(block_uid, function(self, collidee)
            if collidee.velocityy > -0.1 then collidee.velocityy = -0.1 end
            return true
        end)
        return true
    end, "one_way_down")
end

local function deactivate()
    down_blocks = {}
    up_blocks = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
