local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('BotanyKnowledge'))

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
	
	
	local HealSpeed = Code:GetPlayerValue(Player, "HealingSpeed")
	local Bonus = (HealSpeed / 100) * Perk_Module.Tiers[Tier]
	
	_G.GetValue(this.Player.Name, "HealingSpeed"):Add("BotanyKnowledge", Bonus, -1)
	
end

return this
