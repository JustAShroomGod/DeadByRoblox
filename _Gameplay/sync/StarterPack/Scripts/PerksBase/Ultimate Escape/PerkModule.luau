local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("Ultimate Escape"))

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
	
	Events.Survivor.onKillerFlashed.Event:Connect(OnKillerFlashed)
end

function OnKillerFlashed(Killer, Survivor)
	if (Survivor ~= this.Player) then
		return
	end
	
	Code_Module:SetEffect("Haste", Survivor, {Perk_Module.Tiers[this.Tier], Perk_Module.Haste}, "Ultimate_Escape")
	Code_Module:SetEffect("Hidden", Survivor, Perk_Module.Tiers[this.Tier], "Ultimate_Escape")
end

return this
