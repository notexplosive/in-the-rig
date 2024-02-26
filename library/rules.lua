local rules = {}

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
