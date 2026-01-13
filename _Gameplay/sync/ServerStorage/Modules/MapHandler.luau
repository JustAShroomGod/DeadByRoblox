local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MAPS = require(script:WaitForChild('Map_List'))
local Interactions = require(script:WaitForChild('Interactables_Rework'))
local Map = {}

Map.__index = Map

local function SetLighting(lighting : Folder) : "Uploads lighting folder to lighting"
	for i, b in pairs(game.Lighting:GetChildren()) do
		if b then
			b:Destroy()
		end
	end

	for _,obj in pairs(lighting:GetChildren()) do
		obj.Parent = game:GetService("Lighting")
	end

	lighting:Destroy()
end

function Map:Essentials() : "Spawns in workspace essentials"
	local F = Instance.new('Folder', workspace)
	F.Name = 'Beams'
end

function Map:Spawn(array : "Offering List") : "Returns Map metatable"
	local map = {}
	setmetatable(map, Map)

	local Lighting_Settings = "Normal"

	if table.find(array, "Eclipse Card") then
		Lighting_Settings = "Dark"
	end

	if table.find(array, "Full Moon Card") then
		Lighting_Settings = if Lighting_Settings == "Normal" then "Clear" else "Mixed"
	end

	local map, title = nil, nil

	if workspace:GetAttribute("CUSTOM_MAP") then
		map, title = MAPS:Choose(workspace:GetAttribute("CUSTOM_MAP"))
	else
		map, title = MAPS:Generate(array)
	end

	if (map) then
		map.Name = title

		for _, any in pairs(map:GetChildren()) do
			any.Parent = workspace
		end
	end

	Interactions:Spawn(workspace:WaitForChild('Interactables'), map:GetAttributes())

	if (workspace:FindFirstChild("Lighting") ~= nil) then
		SetLighting(workspace:WaitForChild('Lighting'))
	end

	ReplicatedStorage.Match.MapName.Value = title
	
	if ReplicatedStorage.Match.MapName.Value == "Dead Dawg Saloon" or "Library" then
		game.Lighting.ClockTime = 12 --17.472
	elseif ReplicatedStorage.Match.MapName.Value == "Sanctum of Wrath" then
		game.Lighting.ClockTime = 14
		game.Lighting.GeographicLatitude = 0
	end

	--if Lighting_Settings ~= "Normal" then

		--if Lighting_Settings == "Dark" then
			--game.Lighting.ClockTime = 6
			--game.Lighting.Ambient = Color3.fromRGB(85, 0, 255)
			--game.Lighting.Brightness = 0.8
			--game.Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 127)
		--elseif Lighting_Settings == "Clear" then
			--game.Lighting.Brightness = 1
			--game.Lighting.ClockTime = 12
			--game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			--game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		--end
	--end --alla this code might be useless idk
	
	--local halloweenfilter = Instance.new("ColorCorrectionEffect")

	--halloweenfilter.Name = "HalloweenColorCorrection"
	--halloweenfilter.Brightness = .1
	--halloweenfilter.contrast = .2
	--halloweenfilter.enabled = true
	--halloweenfilter.saturation = .1
	--halloweenfilter.tintcolor = Color3.fromRGB(255,220,131)

	--halloweenfilter.Parent = "Lighting"
	
	return map
end

return Map