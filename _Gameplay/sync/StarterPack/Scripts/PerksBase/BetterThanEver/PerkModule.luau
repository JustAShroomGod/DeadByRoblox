local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("BetterThanEver"))

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

	script.Parent:SetAttribute("Duration", Perk_Module.Tiers[this.Tier])
	Events.Survivor.onHookRescue.Event:Connect(OnHookRescue)
end

function OnHookRescue(Rescuer, Rescued)
	
	if (Rescued ~= this.Player) then
		return
	end
	
	ApplyStuff()
end

function ApplyStuff()
	script.Parent:SetAttribute("timestamp", workspace:GetServerTimeNow())
	
	local RepairSpeed = (Code.BaseValues.Survivor.Action.RepairSpeed / 100) * Perk_Module.Speed_Boost
	local HealSpeed = (Code.BaseValues.Survivor.Action.HealingSpeed / 100) * Perk_Module.Speed_Boost
	local CleanseSpeed = (Code.BaseValues.Survivor.Action.CleanseSpeed / 100) * Perk_Module.Speed_Boost
	
	_G.GetValue(this.Player.Name, "RepairSpeed"):Add("BetterThanEver", RepairSpeed * Perk_Module.Speed_Boost, Perk_Module.Tiers[this.Tier])
	_G.GetValue(this.Player.Name, "HealingSpeed"):Add("BetterThanEver", HealSpeed * Perk_Module.Speed_Boost, Perk_Module.Tiers[this.Tier])
	_G.GetValue(this.Player.Name, "CleanseSpeed"):Add("BetterThanEver", CleanseSpeed * Perk_Module.Speed_Boost, Perk_Module.Tiers[this.Tier])
end



return this
