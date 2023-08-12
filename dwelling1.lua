local nocrap = require("Modules.Dregu.no_crap")

local dwelling1 = {
    identifier = "dwelling1",
    title = "Dwelling 1: Bounce Zoo",
    theme = THEME.DWELLING,
    width = 2,
    height = 2,
    file_name = "dwell-1.lvl",
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
        if #players < 1 then return end

        state.camera.adjusted_focus_x = 12.5
        state.camera.adjusted_focus_y = 114.5

    end, ON.FRAME)

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
