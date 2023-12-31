local nocrap = require("Modules.Dregu.no_crap")
local locked_exits = require("Modules.GetimOliver.locked_exits")
local fixed_camera = require("Modules.GetimOliver.fixed_camera")

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

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    fixed_camera.activate(level_state)
    locked_exits.activate(level_state)

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    locked_exits.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
