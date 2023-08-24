
local poor_money_gates = {}
local middle_class_money_gates = {}
local wealthy_money_gates = {}

local texture_definition = TextureDefinition.new()
texture_definition.width = 128
texture_definition.height = 128
texture_definition.tile_width = 128
texture_definition.tile_height = 128
local function money_gate_texture() 
    texture_definition.texture_path = f'Modules/GetimOliver/Textures/money_gate.png'
    local active_texture = define_texture(texture_definition)
    return active_texture
end

local function activate(level_state, poor_gate, middle_gate, wealthy_gate)

    if poor_gate == nil then poor_gate = 10000 end
    if middle_gate == nil then middle_gate = 100000 end
    if wealthy_gate == nil then wealthy_gate = 1000000 end

    define_tile_code("poor_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor:set_texture(money_gate_texture())
        floor.color = Color:blue()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        poor_money_gates[#poor_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "poor_money_gate")

    define_tile_code("middle_class_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor:set_texture(money_gate_texture())
        floor.color = Color:green()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        middle_class_money_gates[#middle_class_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "middle_class_money_gate")

    define_tile_code("wealthy_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor:set_texture(money_gate_texture())
        floor.color = Color:purple()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        wealthy_money_gates[#wealthy_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "wealthy_money_gate")
    
    local frames = 0
    local is_poor = true
    local is_middle_class = false
    local is_wealthy = false
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if #players == 0 then return end
        if (players[1].inventory.money > wealthy_gate) and is_wealthy then
            for i = 1,#wealthy_money_gates do
                kill_entity(wealthy_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.TRAPS_KALI_ANGERED)
                is_wealthy = false
            end
        elseif (players[1].inventory.money > middle_gate) and is_middle_class then
            for i = 1,#middle_class_money_gates do
                kill_entity(middle_class_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.SHOP_SHOP_BUY)
                is_middle_class = false
                is_wealthy = true
            end
        elseif (players[1].inventory.money > poor_gate) and is_poor then
            for i = 1,#poor_money_gates do
                kill_entity(poor_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.SHOP_SHOP_ENTER)
                is_poor = false
                is_middle_class = true
            end
        end
        
        frames = frames + 1
    end, ON.FRAME)
end

local function deactivate()
    poor_money_gates = {}
    middle_class_money_gates = {}
    wealthy_money_gates = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
