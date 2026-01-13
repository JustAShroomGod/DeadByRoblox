local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild(script.Parent.Name))

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
	
	Events.Killer.onHook.Event:Connect(SurvivorHooked)
end

function SurvivorHooked()
	
	local stacks = script.Parent:GetAttribute("Stacks")
	stacks += 1
	
	script.Parent:SetAttribute("Stacks", stacks)
	
	for i, plr in pairs(game.Teams.Survivor:GetPlayers()) do
		_G.GetValue(plr, "SC_Speed"):Add("Pressured", (stacks * Perk_Module[this.Tier]), nil)
	end
	
end

return this
