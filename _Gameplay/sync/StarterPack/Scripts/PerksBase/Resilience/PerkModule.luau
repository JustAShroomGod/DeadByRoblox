local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('Resilience'))
local Values = script.Parent.Parent.Parent.values

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	Values.HealthState.Changed:Connect(OnHealthUpdate)
end

function OnHealthUpdate(HealthState)
	
	local ActionSpeed = Code.BaseValues.Survivor.Action.ActionSpeed
	local RepairSpeed = Code.BaseValues.Survivor.Action.RepairSpeed
	local VaultSpeed = Code.BaseValues.Survivor.Movement.WindowVaultSpeed
	local HealSpeed = Code.BaseValues.Survivor.Action.HealingSpeed
	local CleanseSpeed = Code.BaseValues.Survivor.Action.CleanseSpeed
	local OpeningSpeed = Code.BaseValues.Survivor.Action.OpeningSpeed
	
	if (HealthState == 1) then
		_G.GetValue(this.Player.Name, "ActionSpeed"):Add("Resilience", (ActionSpeed / 100 * Perk_Module.Tiers[this.Tier]), nil)
		_G.GetValue(this.Player.Name, "RepairSpeed"):Add("Resilience", (RepairSpeed / 100 * Perk_Module.Tiers[this.Tier]), nil)
		_G.GetValue(this.Player.Name, "WindowVaultSpeed"):Add("Resilience", -(VaultSpeed / 100 * Perk_Module.Tiers[this.Tier]), nil)
		_G.GetValue(this.Player.Name, "HealingSpeed"):Add("Resilience", (HealSpeed / 100 * Perk_Module.Tiers[this.Tier]), nil)
		_G.GetValue(this.Player.Name, "CleanseSpeed"):Add("Resilience", (CleanseSpeed / 100) * Perk_Module.Tiers[this.Tier], nil)
		_G.GetValue(this.Player.Name, "OpeningSpeed"):Add("Resilience", (OpeningSpeed / 100) * Perk_Module.Tiers[this.Tier], nil)
	else
		_G.GetValue(this.Player.Name, "ActionSpeed"):Remove("Resilience")
		_G.GetValue(this.Player.Name, "RepairSpeed"):Remove("Resilience")
		_G.GetValue(this.Player.Name, "WindowVaultSpeed"):Remove("Resilience")
		_G.GetValue(this.Player.Name, "HealingSpeed"):Remove("Resilience")
		_G.GetValue(this.Player.Name, "CleanseSpeed"):Remove("Resilience")
		_G.GetValue(this.Player.Name, "OpeningSpeed"):Remove("Resilience")
	end
	
end

return this
