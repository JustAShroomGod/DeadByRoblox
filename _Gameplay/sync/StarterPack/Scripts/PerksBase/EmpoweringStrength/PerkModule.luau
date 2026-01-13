local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("EmpoweringStrength"))

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
	
	Events.Survivor.onHookRescue.Event:Connect(HookRescue)
	Events.Survivor.onTotemBreak.Event:Connect(TotemBreak)
end

function HookRescue(Survivor: Player)

	if (Survivor.Name ~= this.Player.Name) then
		return
	end

	local modifier = Perk_Module.Tiers[this.Tier]
	local tokens = script.Parent:GetAttribute("Token")
	tokens += 1

	script.Parent:SetAttribute("Token", tokens)
	_G.GetValue(Survivor.Name, "StunMultiplier"):Add(script.Parent.Name, (modifier * tokens), nil)
end

function TotemBreak(Survivor: Player, Totem: Model)
	
	if (Survivor.Name ~= this.Player.Name) then
		return
	end
	
	local modifier = Perk_Module.Tiers[this.Tier]
	local tokens = script.Parent:GetAttribute("Token")
	tokens += 1
	tokens = math.clamp(tokens, 0, Perk_Module.MaxTokens)
	
	script.Parent:SetAttribute("Token", tokens)
	_G.GetValue(Survivor.Name, "StunMultiplier"):Add(script.Parent.Name, (modifier * tokens), nil)
end

return this
