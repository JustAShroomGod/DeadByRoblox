local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Hex: Ruin"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Totem = nil

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	local totem, success = Perk_Utils.SetHex(Player)
	
	if (success) then
		this.Totem = totem
		script.Parent:SetAttribute("Active", true)
		HookWorkingState()
		
		Events.Survivor.onTotemBreak.Event:Connect(OnTotemBreak)
		Events.Gameplay.onTotemTransfer.Event:Connect(OnTotemTransfer)
	end
end

function HookWorkingState()
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Generator")) then
			v.Panel.BeingWorked.Changed:Connect(function(newValue)
				GeneratorStateUpdate(v, newValue)
			end)
		end
	end
end

function GeneratorStateUpdate(Generator, State)
	
	if (this.Totem == nil) then
		return
	end
	
	if (State == false) then
		local Panel = Generator.Panel
		local Broke = Panel.Broke
		local RegressionSpeed = Panel.RegressionSpeed
		
		if (Perk_Utils.IsHexStanding(this.Totem)) then
			Broke.Value = true
			RegressionSpeed.Value = (100 * Perk_Module.Tiers[this.Tier])
		else
			RegressionSpeed.Value = 100
		end
	end
end

function OnTotemBreak(Survivor: Player, Type, Totem)
	if (Type == "Curse") then
		if (Totem.Name ~= this.Totem.Name) then
			return
		end
		
		script.Parent:SetAttribute("Active", false)
	end
end

function OnTotemTransfer(Totem, NewTotem)
	if (Totem.Name == this.Totem.Name) then
		this.Totem = NewTotem
		script.Parent:SetAttribute("Active", true)
	end
end

return this
