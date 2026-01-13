local Spawn_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Spawns')

local Spawner = {}

function Spawner:Spawn(Spawns : Folder, Version : number) : "Spawn this item type into map"
	Spawns.Parent = Spawn_Storage
end

return Spawner
