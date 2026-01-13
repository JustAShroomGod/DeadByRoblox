local ReplicatedStorage, ServerStorage = game:GetService('ReplicatedStorage'), game:GetService('ServerStorage')

local SOURCE_OF_MODEL = ServerStorage:WaitForChild('Interactables')

local Interactables = {
	Version = 1;
}

local function Build_Wall(interactionFolder : Folder) : "Generates map walls"  -- builds walls around map

	for i,part in pairs(interactionFolder:GetChildren())do
		local P = Instance.new('Part')
		P.Anchored = true
		P.Material = Enum.Material.Brick
		P.Color = Color3.fromRGB(129, 25, 0)
		P.CanCollide = true
		P.Name = 'Wall'..i
		P.Size = part.Size
		P.CFrame = part.CFrame
		P.Parent = workspace
	end

	interactionFolder:Destroy() -- done w/ this folder so we delete it from workspace!
end

function Interactables:Spawn(interactionFolder : "Interaction Folder", attributes : "Map Attributes") : "Spawns the map interactions"
	Interactables.Version = if attributes['Versions'] then math.random(1, attributes['Versions']) else 1
	
	--warn('Selected Version', Interactables.Version)
	
	if interactionFolder:FindFirstChild("Tile") then --has to load prior to interactables
		require(script:WaitForChild("Tile")):Spawn(interactionFolder:FindFirstChild("Tile"), Interactables.Version)
	end
	
	for _, Interaction_Type : Folder in pairs(interactionFolder:GetChildren()) do
		if not script:FindFirstChild(Interaction_Type.Name) or Interaction_Type.Name == "Tile" then continue end
		task.wait() -- put a minor wait to help w/ execution times
		
		if attributes[Interaction_Type.Name] then -- for future
			print('Max amount:', attributes[Interaction_Type.Name])
		end
		
		require(script:WaitForChild(Interaction_Type.Name)):Spawn(Interaction_Type, Interactables.Version)
	end

	interactionFolder:Destroy() -- no need for folder so delete it!
end

return Interactables
