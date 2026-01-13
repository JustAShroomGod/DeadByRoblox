local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local Events = require(game.ServerScriptService["Event System"].Events)
local Code = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))

local AddonValue = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("DarkBreath"))

local this = {}

function this.init()
	
	local Base = PowerValues:GetAttribute("Charge_Rate")
	local Boost = AddonValue.Recharge_Penalty

	local Calc = Base - (Base / 100 * Boost)
	PowerValues:SetAttribute("Charge_Rate", Calc)
	
	PowerModel:SetAttribute("Blinks", 1)
	PowerValues:SetAttribute("MaxBlinks", 1)
	PowerValues:SetAttribute("BlinkCap", 1)
	Events.Killer.onAttack.Event:Connect(OnAttack)
end

function OnAttack(State, SurvivorName)
	
	if (State ~= "Hit" or PowerModel:GetAttribute("State") ~= 5) then
		return
	end
	
	local Survivor = game.Players:FindFirstChild(SurvivorName)
	if (not Survivor) then
		return
	end
	
	local IFrame, AFrame = Code:GetEffect("IFrame", Survivor), Code:GetEffect("AFrame", Survivor)
	if ((AFrame and AFrame.Active) or (IFrame and IFrame.Active)) then
		return
	end
	
	Code:SetHealthState(Survivor, 0)
	
end

return this
