local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Unrelenting_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Unrelenting'))

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

	local Perk = script.Parent
	local WipeSpeed = Code:GetPlayerValue(Player, "WipeSpeed")
	local MissCooldown = Code:GetPlayerValue(Player, "MissCooldown")
	local Bonus = {Unrelenting_Module.Tiers_Air[Tier], Unrelenting_Module.Tiers_Hit[Tier]}

	_G.GetValue(Player.Name, "WipeSpeed"):Add("Unrelenting", WipeSpeed * (Bonus[2] / 100))
	_G.GetValue(Player.Name, "MissCooldown"):Add("Unrelenting", -(MissCooldown * (Bonus[1] / 100)))
end

return this