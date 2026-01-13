local AddonValue = require(game:GetService("ReplicatedStorage"):WaitForChild("Game_Data"):WaitForChild("Addons"):WaitForChild("Killer"):WaitForChild("Pills"))

local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local this = {}

function this.init()
	local Base = PowerValues:GetAttribute("Drain")
	local Bonus = script:GetAttribute("Bonus")
	
	local Calc = Base - (Base * (1 + AddonValue.Duration_Boost/100))  --0.15

	PowerValues:SetAttribute("Drain", Calc)
end

return this
