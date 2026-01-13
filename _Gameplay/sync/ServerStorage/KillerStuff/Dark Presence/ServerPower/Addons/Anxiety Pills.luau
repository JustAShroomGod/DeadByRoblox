local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Anxiety Pills"))

local this = {}

function this.Init()
	PowerValues:SetAttribute("Phantasm_Frequency",AddonValue.Phantasm_Frequency)
end


return this
