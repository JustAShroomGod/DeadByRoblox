local module = {}

function module.DisableCollisionsInRegion(point : CFrame, regionSize : number)
	local min = point.Position - (0.5 * regionSize)
	local max = point.Position + (0.5 * regionSize)
	local region = Region3.new(min, max)
	local collisionHistory = {}
	local parts = workspace:GetPartBoundsInBox(point, regionSize, nil)

	for _, part : BasePart in pairs(parts) do
		collisionHistory[part] = part.CanCollide
		part.CanCollide = false
	end
	
	return collisionHistory
end

function module.EnableCollisions(collisionLibrary)
	for part : BasePart, wasCollidable in pairs(collisionLibrary) do
		part.CanCollide = wasCollidable
	end
end

return module
