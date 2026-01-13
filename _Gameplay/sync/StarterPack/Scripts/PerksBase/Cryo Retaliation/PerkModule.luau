local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Cryo Retaliation"))


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
	
	Events.Survivor.onKillerStun.Event:Connect(KillerStunned)
end

function KillerStunned(Survivor: Player, Killer: Player)

	if (Killer.Name ~= this.Player.Name) then
		return
	end

	if not (workspace:GetServerTimeNow() - script.Parent:GetAttribute("timestamp") >= Perk_Module.Cooldown) then
		warn("ON COOLDOWN")
		return
	end

	repeat task.wait() until Survivor.Backpack.Scripts.values.Action.Value == "Nothing" --so it doesnt give you the effect while dropping the pallet

	Code_Module:SetEffect("Slow", Survivor, {Perk_Module.Tiers[this.Tier], Perk_Module.Slowness_Percentage}, "Cryo_Retaliation")
	script.Parent:SetAttribute("timestamp",workspace:GetServerTimeNow())
end

return this
