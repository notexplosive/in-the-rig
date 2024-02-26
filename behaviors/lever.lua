local rules = require("library/rules")
local lever = {}

local function leverPress(tween, args)
    if args.isPressed then
        tween:interpolate(args.entity.state["animatedObject"].tweenableScale:to(0.8), 0.25, "cubic_fast_slow")
    else
        tween:interpolate(args.entity.state["animatedObject"].tweenableScale:to(1), 0.25, "cubic_fast_slow")
    end
end

function lever.onEnter(self, args)
    self.state["animatedObject"] = World:spawnObject(self.gridPosition)
    self.state["animatedObject"].state:addOtherState(self.state)
    self:setVisible(false)
end

function lever.getColor(self)
    return self.state["tint"]
end

function lever.onBump(self, args)
    World.roomState["levers"] = World.roomState["levers"] or {}
    local color = lever.getColor(self)
    World.roomState["levers"][color] = not rules.isLeverFlipped(color)
end

function lever.onSignal(self, args)
    World:playAsyncAnimation(leverPress, { entity = self, isPressed = rules.isLeverFlipped(lever.getColor(self)) })
end

return lever
