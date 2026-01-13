local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues

local Events = require(game.ServerScriptService["Event System"].Events)
local AddonValues = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer'):WaitForChild("SilverPendant"))

local debounce = 0

local this = {}

function this.init()
	
	local Base = PowerValues:GetAttribute("Charge_Rate")
	local ChargePenalty = AddonValues.Charge_Penalty
	
	local Calc = Base - (Base / 100 * ChargePenalty)
	
	PowerValues:SetAttribute("Charge_Rate", Calc)
	Events.Killer.onAttack.Event:Connect(OnAttack)
end

function OnAttack(State)
	
	if (State ~= "Hit" or PowerModel:GetAttribute("State") ~= 5 or (workspace:GetServerTimeNow() - debounce < 2)) then
		return
	end
	
	local MaxBlinks = PowerValues:GetAttribute("MaxBlinks")
	debounce = workspace:GetServerTimeNow()
	
	if (PowerValues:GetAttribute("BlinkCap") < 2) then
		MaxBlinks = PowerValues:GetAttribute("BlinkCap")
	end
	
	PowerModel:SetAttribute("Blinks", math.clamp(PowerModel:GetAttribute("Blinks") + 1, 0, MaxBlinks))
end

return this
