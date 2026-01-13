local Spawn_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Spawns')

local Spawner = {}

function Spawner:Spawn(Spawns : Folder, Version : number) : "Spawn this item type into map"
	local spawnsTable = Spawns:GetChildren()
	workspace:WaitForChild('Hatch'):SetAttribute("Spawn", spawnsTable[math.random(1,#spawnsTable)].CFrame)
end

return Spawner
