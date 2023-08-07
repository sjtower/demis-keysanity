local nocrap = require("Modules.Dregu.no_crap")
local moving_totems = require("Modules.JayTheBusinessGoose.moving_totems")
local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")
local telescopes = require("Telescopes/telescopes")


define_tile_code("moving_totem")
define_tile_code("totem_switch")

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

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function() 
        if #players < 1 or not telescopes then return end

        state.camera.adjusted_focus_x = 12.5
        state.camera.adjusted_focus_y = 114.5

    end, ON.FRAME)

    moving_totems.activate(level_state)
    signs.activate(level_state, {"Pro Tip: Hit the snake at the bottom of its bounce and hold right"})
    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling1.title)
    end
    

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    moving_totems.deactivate()
    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
