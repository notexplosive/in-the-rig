local water = {}

local function fillAnimation(tween, params)
    local object = World:spawnObject(params.tile.gridPosition)
    object.state:addOtherState(params.tile.state)
    tween:interpolate(object.tweenableScale:to(0), 0.25, "cubic_fast_slow")
end

function water.attemptFill(self, params)
    local filler = params.move:movingEntity()
    if filler:checkTrait("Fillability", "FillsWater") then
        filler:destroy()
        World:playAnimation(fillAnimation, { tile = self })
        World:setTileAt(self.gridPosition, "floor")
    else
        params.move:stop()
    end
end

return water
