local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("PocketWatch"))

local this = {}

function this.init()
	local Base = PowerValues:GetAttribute("Fatigue_Window")
	local RechargeBoost = AddonValue.Window_Boost
	
	local Calc = Base + RechargeBoost
	PowerValues:SetAttribute("Fatigue_Window", Calc)
end

return this
