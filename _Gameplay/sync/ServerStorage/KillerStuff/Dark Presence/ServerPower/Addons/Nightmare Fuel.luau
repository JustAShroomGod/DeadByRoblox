local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Nightmare Fuel"))

local this = {}

function this.Init()
	PowerValues:FindFirstChild("SoundPart"):WaitForChild("TPSound").Volume = PowerValues:FindFirstChild("SoundPart"):WaitForChild("TPSound").Volume * (1 - AddonValue.Sound_Reduction_Multiplier)	
	PowerValues:SetAttribute("Undetectable_Duration", AddonValue.Undetectable_Duration)
end


return this
