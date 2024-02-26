local rules = require("library/rules")
local exit = {}

local function check(self)
    if rules.hasCollectedAllFolders() then
        self.state["speed"] = 10
    end
end

function exit.onEnter(self, args)
    self.state["animatedObject"] = World:spawnObject(self.gridPosition)
    self.state["animatedObject"].state:addOtherState(self.state)
    self:setVisible(false)

    self.state["speed"] = 0.25
    check(self)
end

function exit.onCollect(self, args)
    check(self)
end

function exit.onUpdate(self, args)
    self.state["animatedObject"].tweenableAngle:set(self.state["animatedObject"].tweenableAngle:get() +
        args.dt * self.state["speed"])

    self.state["animatedObject"].tweenableScale:set(0.8)
end

function exit.onStepOn(self, args)
    if rules.hasCollectedAllFolders() then
        World:finishChapter()
    end
end

return exit
