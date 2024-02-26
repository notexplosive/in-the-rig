local raycast = {}

function raycast.cast(start, direction, shouldStop)
    if direction == Soko.DIRECTION.NONE then
        print("attempted raycast in no direction")
        return nil
    end
    local step = direction:toGridPosition()
    local currentPoint = start
    local counter = 0
    while not shouldStop(currentPoint) do
        currentPoint = currentPoint + step
        counter = counter + 1

        if counter > 100 then
            return nil
        end
    end

    return currentPoint
end

return raycast
