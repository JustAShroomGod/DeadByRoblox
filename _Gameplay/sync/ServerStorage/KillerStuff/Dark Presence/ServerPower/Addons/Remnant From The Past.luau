local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Remnant From The Past"))

local this = {}

function this.Init()
	PowerValues:SetAttribute("Phantasm_Lifetime",AddonValue.Phantasm_Lifetime)
	PowerValues:SetAttribute("Wave_Recharge", AddonValue.Wave_Recharge)
end


return this
