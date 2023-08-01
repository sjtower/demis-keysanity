
local inverse_timed_doors = {};
local inverse_timed_switches = {};

local function open_door() 
    for _, door in ipairs(inverse_timed_doors) do
        door.color:set_rgba(217, 224, 252, 100) --white blue, semi-opaque
        door.flags = clr_flag(door.flags, ENT_FLAG.SOLID)
    end
    for _, switch in ipairs(inverse_timed_switches) do
        switch.flags = clr_flag(switch.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    end
end

local function close_door() 
    for _, door in ipairs(inverse_timed_doors) do
        door.color:set_rgba(217, 224, 252, 255) --white blue
        door.flags = set_flag(door.flags, ENT_FLAG.SOLID)
    end
    for _, switch in ipairs(inverse_timed_switches) do
        switch.flags = set_flag(switch.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    end
end

local function activate(level_state, time)
    -- Creates a wall that opens for a time when a switch is hit
    define_tile_code("inverse_timed_door_switch")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local ent = get_entity(switch_id)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color:set_rgba(180, 240, 177, 250) --Light Green
        inverse_timed_switches[#inverse_timed_switches + 1] = ent
        local door_timer = time
        local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
        local isActive = false
        level_state.callbacks[#level_state.callbacks+1] = set_on_damage(switch_id, function(self)
            if self.timer > 0 or isActive then return end
            self.timer = door_timer
            self.animation_frame = self.animation_frame == 86 and 96 or 86
            close_door()
            sound:play()
            isActive = true
            level_state.callbacks[#level_state.callbacks+1] = set_timeout(function()
                self.animation_frame = self.animation_frame == 86 and 96 or 86
                open_door()
                sound:play()
                isActive = false
            end, door_timer)
        end)
    end, "inverse_timed_door_switch")

    define_tile_code("inverse_timed_door")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
        ent.color:set_rgba(180, 240, 177, 100) --light green, semi-opaque
        inverse_timed_doors[#inverse_timed_doors + 1] = ent
        return true
    end, "inverse_timed_door")
end

local function deactivate()
    inverse_timed_doors = {}
    inverse_timed_switches = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
