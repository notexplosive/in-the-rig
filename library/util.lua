local util = {}

function util.getLayer(thing)
    if thing:isTile() then
        return -1
    end

    return thing.state["layer"] or 0
end

return util
