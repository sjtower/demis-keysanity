-- oneway dustwalls that push you in whatever direction. doesn't affect movement if already moving in the right way
define_tile_code("dustwall_right")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn(ENT_TYPE.FLOOR_DUSTWALL, x, y, layer, 0, 0)
    local ent = get_entity(uid)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
    ent.hitboxx = 0.45
    ent.hitboxy = 0.45
    set_pre_collision2(uid, function(self, collidee)
        if collidee.velocityx < 0.1 then collidee.velocityx = 0.1 end
        return true
    end)
    return true
end, "dustwall_right")

define_tile_code("dustwall_left")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn(ENT_TYPE.FLOOR_DUSTWALL, x, y, layer, 0, 0)
    local ent = get_entity(uid)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
    ent.hitboxx = 0.45
    ent.hitboxy = 0.45
    set_pre_collision2(uid, function(self, collidee)
        if collidee.velocityx > -0.1 then collidee.velocityx = -0.1 end
        return true
    end)
    return true
end, "dustwall_left")

define_tile_code("dustwall_down")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn(ENT_TYPE.FLOOR_DUSTWALL, x, y, layer, 0, 0)
    local ent = get_entity(uid)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
    ent.hitboxx = 0.45
    ent.hitboxy = 0.45
    set_pre_collision2(uid, function(self, collidee)
        if collidee.velocityy > -0.1 then collidee.velocityy = -0.1 end
        return true
    end)
    return true
end, "dustwall_down")

define_tile_code("dustwall_up")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn(ENT_TYPE.FLOOR_DUSTWALL, x, y, layer, 0, 0)
    local ent = get_entity(uid)
    ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
    ent.hitboxx = 0.45
    ent.hitboxy = 0.45
    set_pre_collision2(uid, function(self, collidee)
        if collidee.velocityy < 0.1 then collidee.velocityy = 0.1 end
        return true
    end)
    return true
end, "dustwall_up")