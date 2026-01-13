local Interactables = workspace:WaitForChild('Interactables')

local Object = {
	Rotations = {45,90,120,180,0}
}

function Object:Spawn(Objects : Folder, Version : number) : "Spawn this item type into map"
	if not workspace:FindFirstChild("Map"):FindFirstChild("Prefabs"):FindFirstChild("Tile") then return end

	local Tiles = workspace:FindFirstChild("Map"):FindFirstChild("Prefabs"):FindFirstChild("Tile")

	for _, Location : Instance in pairs(Objects:GetChildren()) do
		if Location:GetAttribute("Version") and Location:GetAttribute("Version") ~= Version then continue end

		for _, SpawnPoints in pairs(Location:GetChildren()) do
			local Tile = Tiles:GetChildren()[math.random(#Tiles:GetChildren())]:Clone()
			
			Tile:PivotTo(SpawnPoints:GetPivot() * CFrame.Angles(0,math.rad(Object.Rotations[math.random(1, #Object.Rotations)]),0))
			
			for _,Interactable in pairs(Tile:FindFirstChild("Interactables"):GetChildren()) do
				local Interactable_Folder = Interactables:FindFirstChild(Interactable.Name)

				if Interactable_Folder:FindFirstChild(tostring("Version" .. Version)) then
					Interactable.Parent = Interactable_Folder:FindFirstChild(tostring("Version" .. Version))
				else
					Interactable.Parent = Interactable_Folder
				end

				Interactable.Name = "Location"
			end
			
			Tile:FindFirstChild("Interactables"):Destroy()
			Tile.Parent = workspace
		end
	end
	
	Tiles:Destroy()
end

return Object
