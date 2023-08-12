local function activate(level_state)
    -- fix camera to center of stage (2x2 only)
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function() 
        if #players < 1 then return end

        state.camera.adjusted_focus_x = 12.5
        state.camera.adjusted_focus_y = 114.5

    end, ON.FRAME)
end

local function deactivate()
    --do nothing
end

return {
    activate = activate,
    deactivate = deactivate
}
