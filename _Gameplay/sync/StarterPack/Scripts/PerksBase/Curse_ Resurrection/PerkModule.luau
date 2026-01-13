local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Curse: Resurrection"))

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
		this.Totem:SetAttribute("Effect", "Curse: Resurrection")
		
		Events.Survivor.onTotemBreak.Event:Connect(OnTotemBreak)
	end
end

function OnTotemBreak(Survivor: Player, Type, Totem)
	
	if (not Perk_Utils.IsHexStanding(this.Totem) or this.Totem == nil) then
		return
	end
	
	if (Type == "Curse") then
		if (Totem.Name ~= this.Totem.Name) then
			Perk_Utils.TransferHex(this.Player, Totem, this.Totem)
			script.Parent:SetAttribute("Active", false)
			this.Totem = nil
		else
			script.Parent:SetAttribute("Active", false)
		end
	end
end

return this
