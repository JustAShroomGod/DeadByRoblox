local Events = require(game.ServerScriptService["Event System"].Events)
local RunService = game:GetService("RunService")
local Code = require(game.ReplicatedStorage.Modules.Code)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('MedicalRemains'))


local this = {}

this.Player = nil
this.initialized = false
this.Heartbeat = nil


function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	script.Parent:SetAttribute("MaxProgress", Perk_Module.MaxCharges)
	RunService.Heartbeat:Connect(Update)
	
end

function Update(delta)
	
	local PerkValues = script.Parent	
	local Progress = PerkValues:GetAttribute("Progress")
	local Scripts = this.Player.Backpack.Scripts
	local Action = Scripts.values.Action.Value
	local Bonus = (Code.BaseValues.Survivor.Action.RepairSpeed / 100) * Perk_Module.Tiers[this.Tier]

	if (Action == "Repairing") then
		PerkValues:SetAttribute("Progress", math.clamp(Progress - delta, 0, Perk_Module.MaxCharges))
	end

	if (Action == "OtherHealing") then
		PerkValues:SetAttribute("Progress", math.clamp(Progress + delta, 0, Perk_Module.MaxCharges))
	end

	if (Action == "SelfHealing") then
		PerkValues:SetAttribute("Progress", math.clamp(Progress + delta, 0, Perk_Module.MaxCharges))
	end

	if (Action == "MedkitHeal") then
		PerkValues:SetAttribute("Progress", math.clamp(Progress + delta, 0, Perk_Module.MaxCharges))
	end

	if (Progress > 0) then
		_G.GetValue(this.Player.Name, "RepairSpeed"):Add("MedicalRemains", Bonus, -1)
	else
		_G.GetValue(this.Player.Name, "RepairSpeed"):Remove("MedicalRemains")
	end
	
end

return this
