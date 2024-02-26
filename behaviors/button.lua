local rules = require("library/rules")
local button = {}

local function buttonPress(tween, args)
    if args.isPressed then
        tween:interpolate(args.entity.state["animatedObject"].tweenableScale:to(0.8), 0.25, "cubic_fast_slow")
    else
        tween:interpolate(args.entity.state["animatedObject"].tweenableScale:to(1), 0.25, "cubic_fast_slow")
    end
end

function button.onEnter(self, args)
    self.state["animatedObject"] = World:spawnObject(self.gridPosition)
    self.state["animatedObject"].state:addOtherState(self.state)
    self:setVisible(false)
end

function button.getColor(self)
    return self.state["tint"]
end

function button.onSignal(self, args)
    World:playAsyncAnimation(buttonPress, { entity = self, isPressed = rules.isPressedAt(self.gridPosition) })
end

return button
