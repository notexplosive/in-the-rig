local rules = require("library/rules")
local door = {}

function door.onSignal(self, args)
    local signalColor = self.state["tint"]

    if args.signalFlagTable[signalColor] then
        self:setVisible(false)
        self:setTraitName("Phase", "Immaterial")
        self:setTraitName("Swapability", "SwapAgnostic")
    else
        self:setVisible(true)
        self:setTraitName("Phase", "Solid")
        self:setTraitName("Swapability", "CancelSwap")

        for i, entity in ipairs(World:getEntitiesAt(self.gridPosition)) do
            if entity ~= self and rules.isCorporeal(entity) then
                entity:destroy()
            end
        end
    end
end

return door
