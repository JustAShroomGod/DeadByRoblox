local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild(script.Parent.Name))

local Remotes = game.ReplicatedStorage.RemoteEvents.ServerToClient

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
	
	script.Parent:SetAttribute("extension", Perk_Module.Tiers[this.Tier])
	Events.Survivor.onKillerStun.Event:Connect(SurvivorUnhooked)
end

function SurvivorUnhooked(Survivor: Player, Killer: Player)
	
	local token = script.Parent:GetAttribute("token") + 1
	
	script.Parent:SetAttribute("token", token)
	_G.GetValue(this.Player.Name, "AuraExtension"):Add("GrowingFixation", (Perk_Module.Tiers[this.Tier] * token), nil)
	
	script.Parent:SetAttribute("timestamp", workspace:GetServerTimeNow())
	script.Parent:SetAttribute("player", Killer.Name)
	
	for i, v in pairs(game.Teams.Survivor:GetPlayers()) do
		if (v.Name == this.Player.Name) then
			continue
		end
		
		Remotes.AuraEvent:FireClient(v, "FullFocus")
	end
end

return this
