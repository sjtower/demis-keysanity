local on_off_blocks = {};
local on_off_switches = {};

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128
local function on_off_block_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/on_off_block.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function toggle_blocks() 
    for _, block in ipairs(on_off_blocks) do
        local flags = get_entity_flags(block.uid)
        if test_flag(flags, ENT_FLAG.LOCKED) then --LOCKED == red
            if test_flag(flags, ENT_FLAG.SOLID) then
				block.color:set_rgba(255, 40, 0, 150) --Red, Transparent
                block.flags = clr_flag(block.flags, ENT_FLAG.SOLID)
            else
                block.color:set_rgba(255, 40, 0, 255) --Red, Solid
                block.flags = set_flag(block.flags, ENT_FLAG.SOLID)
            end
        else
            if test_flag(flags, ENT_FLAG.SOLID) then
                block.color:set_rgba(0, 100, 255, 150) --Light Blue, Transparent
                block.flags = clr_flag(block.flags, ENT_FLAG.SOLID)
            else
                block.color:set_rgba(0, 100, 255, 255) --Light Blue, Solid
                block.flags = set_flag(block.flags, ENT_FLAG.SOLID)
            end
        end
    end
end

local function activate(level_state, time)
    if time == nil then
        time = 60
    end
    -- Toggles on and off blocks when a switch is hit
    define_tile_code("on_off_switch")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:white()
        on_off_switches[#on_off_switches + 1] = switch
        local switch_timer = time
        local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
        set_on_damage(switch.uid, function(self)
            if self.timer > 0 then return end
            self.timer = switch_timer
            self.animation_frame = self.animation_frame == 86 and 96 or 86
            toggle_blocks()
            sound:play()
            set_timeout(function() --switch goes back into place
                self.animation_frame = self.animation_frame == 86 and 96 or 86
                self.timer = 0
            end, switch_timer)
        end)
    end, "on_off_switch")

    define_tile_code("on_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent:set_texture(on_off_block_texture())
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
        ent.color:set_rgba(0, 100, 255, 150) --Light Blue, Transparent
        ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT) --Unpushable
        on_off_blocks[#on_off_blocks + 1] = ent
        return true
    end, "on_block")

    define_tile_code("off_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent:set_texture(on_off_block_texture())
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.color:set_rgba(255, 40, 0, 250) --Red, Solid
        ent.flags = set_flag(ent.flags, ENT_FLAG.SOLID)
        ent.flags = set_flag(ent.flags, ENT_FLAG.LOCKED)
        ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT) --Unpushable
        on_off_blocks[#on_off_blocks + 1] = ent
        return true
    end, "off_block")
end

local function deactivate()
    on_off_blocks = {}
    on_off_switches = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
