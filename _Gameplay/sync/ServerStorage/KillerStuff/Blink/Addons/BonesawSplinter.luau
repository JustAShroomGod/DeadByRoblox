local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("BonesawSplinter"))

local this = {}

function this.init()
	local Base = PowerValues:GetAttribute("Distance_Max")
	local DistanceBoost = AddonValue.Distance_Boost --script:GetAttribute("Bonus")
	
	local Calc = Base + (Base / 100 * DistanceBoost)
	PowerValues:SetAttribute("Distance_Max", Calc)
end

return this
