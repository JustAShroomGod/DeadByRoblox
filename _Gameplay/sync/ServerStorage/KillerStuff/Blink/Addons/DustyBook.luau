local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValues = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("DustyBook"))

local this = {}

function this.init()
	local Base = PowerValues:GetAttribute("MaxBlinks")
	local BlinkBonus = AddonValues.Blink_Boost
	
	local Base2 = PowerValues:GetAttribute("Charge_Rate")
	local ChargePenalty = AddonValues.Charge_Penalty
	
	local Calc = Base + BlinkBonus
	local Calc2 = Base2 - (Base2 / 100 * ChargePenalty)
	
	if (PowerValues:GetAttribute("BlinkCap") < 2) then
		Calc = PowerValues:GetAttribute("BlinkCap")
	end
	
	PowerValues:SetAttribute("MaxBlinks", Calc)
	PowerValues:SetAttribute("Charge_Rate", Calc2)
end

return this
