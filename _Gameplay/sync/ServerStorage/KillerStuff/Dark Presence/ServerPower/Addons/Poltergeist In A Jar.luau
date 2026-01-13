local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Poltergeist In A Jar"))

local this = {}

function this.Init()
	PowerValues:SetAttribute("Interactable_Block_Duration",AddonValue.Interactable_Block_Duration)
	PowerValues:SetAttribute("Wave_Recharge", AddonValue.Wave_Recharge)
end


return this
