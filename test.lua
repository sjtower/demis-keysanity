local nocrap = require("Modules.Dregu.no_crap")
local locked_exits = require("Modules.GetimOliver.locked_exits")
local fixed_camera = require("Modules.GetimOliver.fixed_camera")
local breaking_blocks = require("Modules.GetimOliver.breaking_blocks")
local one_way_walls = require("Modules.GetimOliver.one_way_walls")
local player_only_blocks = require("Modules.GetimOliver.player_only_blocks")
local dustwalls = require("Modules.Dregu.dustwalls")
local one_way_platforms = require("Modules.GetimOliver.one_way_platforms")
local no_player_blocks = require("Modules.GetimOliver.no_player_blocks")

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
    breaking_blocks.activate(level_state)
    one_way_walls.activate(level_state)
    one_way_platforms.activate(level_state)
    player_only_blocks.activate(level_state)
    no_player_blocks.activate(level_state)

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    locked_exits.deactivate()
    breaking_blocks.deactivate()
    one_way_walls.deactivate()
    one_way_platforms.deactivate()
    player_only_blocks.deactivate()
    no_player_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
