local folder = {}


function folder.onEnter(self, args)
    if World.levelState["folders"][MAGIC(self.gridPosition)] then
        self:destroy()
        return
    end

    self.state["animatedObject"] = World:spawnObject(self.gridPosition)
    self.state["animatedObject"].state:addOtherState(self.state)
    self:setVisible(false)
end

function folder.onUpdate(self, args)
    self.state["lifetime"] = (self.state["lifetime"] or 0) + args.dt * 5
    self.state["animatedObject"].tweenableAngle:set(math.sin(self.state["lifetime"]) / 8)
end

function folder.onStepOn(self, args)
    print("completed", self.gridPosition)
    World.levelState["folders"][MAGIC(self.gridPosition)] = true
    self:destroy()
    self.state["animatedObject"]:destroy()
    World:raiseEvent("onCollect", {})
end

return folder
