local waterSpawnProp = {}

local function oscillateAnimation(tween, params)
    local object = params.object
    local scaleVariance = 0.25
    tween:startLoopSequence()
    tween:callback(function()
        object.tweenableScale:set(1 - scaleVariance)
    end)
    tween:interpolate(object.tweenableScale:to(1 - scaleVariance * 2), 5, "linear")
    tween:interpolate(object.tweenableScale:to(1 - scaleVariance), 5, "linear")
    tween:endSequence()
end

function waterSpawnProp:onEnter(args)
    local object = World:spawnObject(self.gridPosition)
    object.state:addOtherState(self.state)
    object.state["renderer"] = "SingleFrame"
    object.state["layer"] = 1
    object.state["tint"] = "wall"

    World:playAsyncAnimation(oscillateAnimation, { object = object })
end

return waterSpawnProp
