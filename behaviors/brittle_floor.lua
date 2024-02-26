local brittleFloor = {}

function brittleFloor.onStepOff(self, args)
    if args.move:movingEntity():checkTrait("Phase", "Solid") then
        World:setTileAt(self.gridPosition, "water")
    end
end

return brittleFloor
