local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Cold Comfort"))

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
	
	Events.Server.Heartbeat.Event:Connect(ChaseCount)
end

function ChaseCount(delta)
	local Timer = script.Parent:GetAttribute("Count")

	if Timer >= Perk_Module.Tiers[this.Tier] then
		script.Parent:SetAttribute("Active", true)
	else
		script.Parent:SetAttribute("Active", false)
	end

	if not this.Player.Character:GetAttribute("Chased") then
		return
	end
	
	if Timer < Perk_Module.Tiers[this.Tier] then
		Timer = math.clamp(Timer + delta, 0, Perk_Module.Tiers[this.Tier])
		script.Parent:SetAttribute("Count", Timer)
	end
end

return this
