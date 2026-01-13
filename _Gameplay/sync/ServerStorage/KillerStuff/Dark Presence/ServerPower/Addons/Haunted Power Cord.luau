local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Haunted Power Cord"))

local this = {}

local function returnUnfinishedGenerator()
	local Generator = nil

	for _, v in pairs(workspace:GetChildren()) do
		if not (v:IsA("Model")) or not (string.match(v.Name,"Generator")) then
			continue
		end

		if v:FindFirstChild("Panel"):FindFirstChild("Progress").Value < 1000 then
			Generator = v
			break
		end
	end

	return Generator
end

local function returnRandomCFrame(Part : Part, MaxDistance : number)
	local RandomCFrame = CFrame.new(
		math.random(-MaxDistance, MaxDistance),
		0,
		math.random(-MaxDistance, MaxDistance)
	)
	
	return Part.CFrame * RandomCFrame
end

function this.Init(SpawnPhantasm, KillerPlayer)
	Events.Killer.onHook.Event:Connect(function()
		onHook(SpawnPhantasm, KillerPlayer)
	end)
end

function onHook(SpawnPhantasm, KillerPlayer)
	if workspace:FindFirstChild("MatchValues").GeneratorsRepaired.Value >= 5 then return end
	
	for i = 1, AddonValue.Amount_Spawned do
		local Generator = returnUnfinishedGenerator()
		
		SpawnPhantasm(KillerPlayer.Character, returnRandomCFrame(Generator.PrimaryPart, AddonValue.Distance_From_Generator))
	end
end

return this
