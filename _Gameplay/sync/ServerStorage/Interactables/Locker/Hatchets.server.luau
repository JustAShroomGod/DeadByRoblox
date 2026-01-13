local obj = script.Parent
Instance.new("ObjectValue", game.ReplicatedStorage["-LockerAuras"]).Value = obj
local killerStuff = game.ReplicatedStorage.KillerStuff
local hatchet_copy = killerStuff.Hatchet.Handle:Clone()

for _, child in pairs (hatchet_copy:GetChildren()) do
	child:Destroy()
end

hatchet_copy.Anchored = true

for _, part in pairs(script:GetChildren()) do
	local copy = hatchet_copy:Clone()
	copy.CFrame = part.CFrame
	copy.Anchored = false
	copy.Parent = script
	copy.Name = part.Name

	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.Name = "Part"

	local weld = Instance.new("WeldConstraint", script)
	weld.Part0 = obj.RootPart
	weld.Part1 = part

	local weld = Instance.new("WeldConstraint", script)
	weld.Part0 = obj.RootPart
	weld.Part1 = copy
end
