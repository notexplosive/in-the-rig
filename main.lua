local rules = require("library/rules")
local player = require("library/player")
local exports = {}
-- !! note: These generated functions may not have the correct parameters !!
-- For example, onInput() should be onInput(input), but the generator doesn't support that yet


function exports.onLoadLevel()
    player.spawn()
end

function exports.onInput(input)
    player.handleInput(input)
    World:update()
end

function exports.onRoomStateChanged()

end

function exports.onEntityDestroyed(entity)
    if entity == PLAYER then
        World:resetRoom()
    end

    -- todo: poof vfx
end

function exports.onEnter()
    World:raiseEvent("onEnter", {})
end

function exports.onTurn()
    local availableSignals = {}
    local fulfilledSignals = {}

    World.levelState["player_direction"] = PLAYER.facingDirection
    for i, entity in ipairs(World:allEntitiesInRoom()) do
        if entity.state["tag"] == "button" then
            availableSignals[entity.state["tint"]] = (availableSignals[entity.state["tint"]] or 0) + 1
            fulfilledSignals[entity.state["tint"]] = fulfilledSignals[entity.state["tint"]] or 0
            if rules.isPressedAt(entity.gridPosition) then
                fulfilledSignals[entity.state["tint"]] = fulfilledSignals[entity.state["tint"]] + 1
            end
        end
    end

    local signalFlagTable = {}
    for i, key in ipairs(Soko:keysFromTable(availableSignals)) do
        if availableSignals[key] > 0 and availableSignals[key] == fulfilledSignals[key] then
            signalFlagTable[key] = true
        end
    end

    World:raiseEvent("onSignal", { signalFlagTable = signalFlagTable })
end

function exports.onLoadCheckpoint()
    player.spawn()
end

function exports.onLeave()
end

function exports.onStart()
    World.camera:hideVignetteInstant()
end

function exports.onUpdate()
end

function exports.onMove(move)
    local mover = move:movingEntity()
    local destination = move:targetPosition()
    local source = move:startPosition()

    local moverPhase = mover:getTrait("Phase")
    local moverHeight = mover:getTrait("Height")
    local canDoEasy = mover:getTrait("Strength") >= 10
    local canDoHard = mover:getTrait("Strength") >= 20
    local ignorePhase = moverPhase == 0

    if ignorePhase then
        return
    end

    -- check for solid ground
    local hasValidGround = false
    for i, gridling in ipairs(World:getGridlingsAt(destination)) do
        if gridling:getTrait("Height") < moverHeight and rules.isSamePhase(gridling, mover) then
            hasValidGround = true
        end
    end

    if not hasValidGround then
        World:raiseEventAt(destination, "attemptFill", { move = move })
    end

    -- check for blockers / pushables / etc
    for i, gridling in ipairs(World:getGridlingsAt(destination)) do
        if rules.isSamePhase(gridling, mover) and gridling:getTrait("Height") == moverHeight then
            local pushable = rules.getPushability(gridling)
            if (pushable == "EASY" and canDoEasy) or (pushable == "HARD" and canDoHard) then
                local newMove = gridling:asEntity():generateDirectionalMove(move.direction)
                newMove:execute()

                if not newMove:isAllowed() or pushable == "HARD" then
                    move:stop()
                end
            else
                move:stop()
            end
        end
    end

    World:raiseEventAt(source, "onStepOff", { move = move })
end

return exports
