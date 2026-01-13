local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('BrutalStrength'))

-- Basically pulls values from game_data module instead of attributes now verox ^, same values though --

local this = {}

this.Player = nil
this.initialized = false

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	
	if (this.initialized) then
		return
	end
	
	this.initialized = true
	this.Player = Player
	
	local PalletSpeed = Code:GetPlayerValue(Player, "PalletBreakSpeed")
	PalletSpeed = PalletSpeed * (.5 - Perk_Module.Tiers[Tier])
	
	_G.GetValue(Player.Name, "PalletBreakSpeed"):Add("BrutalStrength", PalletSpeed, -1)
	_G.GetValue(Player.Name, "WallBreakSpeed"):Add("BrutalStrength", PalletSpeed, -1)
end

return this
