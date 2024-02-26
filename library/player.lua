local util = require("library.util")
local raycast = require("library/raycast")
local player = {}

local function flickerColorAnimation(tween, params)
    for i = 1, 2 do
        tween:callback(function()
            params.player.state["tint"] = "swap"
            params.object.state["color"] = "player"
            params.object.state["tint"] = "player"
        end)

        tween:wait(0.05)

        tween:callback(function()
            params.player.state["tint"] = "player"
            params.object.state["color"] = "swap"
            params.object.state["tint"] = "swap"
        end)

        tween:wait(0.05)
    end
end

local function checkRoomTransition(startPosition, newPosition)
    local oldRoom = World:getRoomAtGridPosition(startPosition)
    local newRoom = World:getRoomAtGridPosition(newPosition)

    if oldRoom ~= newRoom then
        local direction = PLAYER.facingDirection
        World.levelState["force_spawn_position"] = newPosition
        World:loadRoom(newRoom)
        World.camera:snapToRoom(newRoom)
        player.spawn()
        PLAYER.facingDirection = direction
    end
end

local function postSwapBobAnimation(tween, params)
    local entity = params.entity

    tween:interpolate(
        entity:displacementTweenable():to(
            Soko.toWorldPosition(params.direction:toGridPosition()) / 4), 0.15, "quadratic_fast_slow"
    )

    tween:interpolate(
        entity:displacementTweenable():to(
            Soko:worldPosition(0, 0)), 0.15, "quadratic_slow_fast"
    )
end

local function finishSwap(tween, params)
    local thingToSwap = params.thingToSwap
    local myPosition = params.myPosition
    local targetPosition = params.targetPosition

    tween:dynamic(
        function()
            if thingToSwap:isEntity() then
                thingToSwap.gridPosition = myPosition
                World:playAsyncAnimation(postSwapBobAnimation,
                    { entity = thingToSwap, direction = PLAYER.facingDirection:next():next() })

                World:playAsyncAnimation(flickerColorAnimation,
                    { object = thingToSwap, player = PLAYER })
            else
                local oldTile = World:getTileAt(myPosition):templateName()
                World:setTileAt(myPosition, thingToSwap:templateName())
                World:setTileAt(targetPosition, oldTile)
            end

            PLAYER.gridPosition = targetPosition

            tween:dynamic(function()
                checkRoomTransition(myPosition, targetPosition)
                postSwapBobAnimation(tween, { entity = PLAYER, direction = PLAYER.facingDirection })
            end)
        end
    )
end

local function fireSwapGun(tween, params)
    local thingToSwap = params.thingToSwap
    local myPosition = PLAYER.gridPosition
    local hitPosition = params.hitPosition

    local projectile = World:spawnObject(PLAYER.gridPosition)

    projectile.state["sheet"] = "sheet"
    projectile.state["renderer"] = "SingleFrame"
    projectile.state["frame"] = 1
    projectile.state["tint"] = "player"

    local gridDisplacement = hitPosition - PLAYER.gridPosition

    local duration = 0
    if PLAYER.facingDirection == Soko.DIRECTION.LEFT or PLAYER.facingDirection == Soko.DIRECTION.RIGHT then
        duration = math.abs(gridDisplacement.x)
    else
        duration = math.abs(gridDisplacement.y)
    end

    duration = duration / 20

    tween:interpolate(projectile.tweenablePosition:to(Soko:toWorldPosition(hitPosition)), duration, "linear")

    if thingToSwap ~= nil then
        finishSwap(tween, {
            thingToSwap = thingToSwap,
            myPosition = myPosition,
            targetPosition = hitPosition,
            projectile = projectile
        })
    else
    end


    tween:callback(function()
        projectile:destroy()
    end)
end

function player.spawn()
    local playerSpawnPosition = World.levelState["force_spawn_position"]
    local playerEntity = World.levelState["player"]
    local playerDirection = World.levelState["player_direction"] or Soko.DIRECTION.DOWN
    if playerEntity ~= nil then
        PLAYER = World:spawnEntity(playerSpawnPosition, playerDirection, playerEntity)
        local newRoom = World:getRoomAtGridPosition(playerSpawnPosition)
        World:loadRoom(newRoom)
        World.camera:snapToRoom(newRoom)

        local arrow = World:spawnObject(PLAYER.gridPosition)
        arrow.state["layer"] = PLAYER.state["layer"]
        arrow.state["renderer"] = "lua"
        arrow.state["render_function"] = function(painter, drawArguments)
            -- painter:setColor(PLAYER.state["tint"] or "white")
            local directionOffset = Soko:toWorldPosition(PLAYER.facingDirection:toGridPosition())
            local entityOffset = PLAYER:displacementTweenable():get()
            local position = Soko:toWorldPosition(PLAYER.gridPosition) + Soko:getHalfTileSize() + directionOffset / 2 +
                entityOffset
            painter:drawFirstFrame("arrow", position, PLAYER.facingDirection:toAngle() + math.pi / 2)
        end

        PLAYER.state["facing_arrow"] = arrow


        -- destroy any entities are swappable here (guessing we probably swapped into this room)
        if World:getTileAt(playerSpawnPosition):checkTrait("Swapability", "CanSwap") then
            World.setTileAt(playerSpawnPosition, "floor")
        end

        for i, entity in ipairs(World:getEntitiesAt(playerSpawnPosition)) do
            if entity:checkTrait("Swapability", "CanSwap") then
                entity:destroy()
            end
        end
    end
end

function player.handleInput(input)
    if input.direction ~= Soko.DIRECTION.NONE then
        local move = PLAYER:generateDirectionalMove(input.direction)
        move:execute()

        if move:isAllowed() then
            local startPosition = move:startPosition()
            local newPosition = move:targetPosition()

            checkRoomTransition(startPosition, newPosition)
        end
    end

    if input.isPrimary then
        local function shouldStopCast(position)
            for i, gridling in ipairs(World:getGridlingsAt(position)) do
                if gridling:getTrait("Swapability") ~= 0 then
                    return true
                end
            end

            return false
        end

        local raycastResult = raycast.cast(PLAYER.gridPosition + PLAYER.facingDirection:toGridPosition(),
            PLAYER.facingDirection, shouldStopCast)
        if raycastResult then
            local thingToSwap = nil

            local candidates = Soko:list()
            for i, gridling in ipairs(World:getGridlingsAt(raycastResult)) do
                if gridling:checkTrait("Swapability", "CanSwap") then
                    candidates:add(gridling)
                end
            end

            local numberOfCandidates = #candidates

            if numberOfCandidates == 1 then
                thingToSwap = candidates[1]
            end
            if numberOfCandidates > 1 then
                candidates:sort(function(a, b)
                    return util.getLayer(b) - util.getLayer(a)
                end)
                thingToSwap = candidates[1]
            end

            World:playAnimation(fireSwapGun, { thingToSwap = thingToSwap, hitPosition = raycastResult })
        else
            -- missed
            World:playAnimation(fireSwapGun,
                { thingToSwap = nil, hitPosition = PLAYER.gridPosition + PLAYER.facingDirection:toGridPosition() * 10 })
        end
    end
end

return player
