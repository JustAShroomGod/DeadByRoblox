local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("AtaxicRespiration"))

local this = {}

function this.init()
	local Base = PowerValues:GetAttribute("Charge_Rate")
	local Boost = AddonValue.Recharge_Boost
	
	local Calc = Base + (Base / 100 * Boost)
	PowerValues:SetAttribute("Charge_Rate", Calc)
end

return this
