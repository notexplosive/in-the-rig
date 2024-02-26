local rules = {}

function rules.isSamePhase(gridling, mover)
    local phase = gridling:getTrait("Phase")
    return phase == mover:getTrait("Phase") or (mover == PLAYER and phase == 15)
end

function rules.isCorporeal(entity)
    return entity:checkTrait("Phase", "Solid") and entity:checkTrait("Height", "Body")
end

function rules.isPressedAt(gridPosition)
    for i, entity in ipairs(World:getEntitiesAt(gridPosition)) do
        if entity:checkTrait("Phase", "Solid") and entity:checkTrait("Height", "Body") then
            return true
        end
    end
end

function rules.getPushability(gridling)
    local entity = gridling:asEntity()
    if entity ~= nil then
        local pushable = entity:getTrait("Pushability")
        if pushable == 0 then
            return "NOT_PUSHABLE"
        end

        if pushable == 10 then
            return "EASY"
        end

        if pushable == 20 then
            return "HARD"
        end
    else
        -- tiles are never pushable
        return "NOT_PUSHABLE"
    end
end

return rules
