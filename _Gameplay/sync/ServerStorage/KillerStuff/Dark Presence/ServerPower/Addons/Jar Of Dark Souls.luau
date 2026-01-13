local Events = require(game.ServerScriptService["Event System"].Events)

local PowerModel = script.Parent.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("Jar Of Dark Souls"))

local this = {}

function this.Init()
	PowerValues:SetAttribute("Wave_Travel_Time", PowerValues:GetAttribute("Wave_Travel_Time") * (1 - AddonValue.Wave_Travel_Time_Multiplier))
end


return this
