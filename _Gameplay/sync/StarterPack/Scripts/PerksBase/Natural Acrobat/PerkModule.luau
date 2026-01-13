local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local RunService = game:GetService("RunService")

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild('Natural Acrobat'))

local this = {}

this.Player = nil
this.initialized = false
this.Heartbeat = nil
this.Tier = 0
this.lastSpeed = 0
this.initTime = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	local Vault_Speed = Code:GetPlayerValue(Player, "WindowVaultSpeed")
	Vault_Speed = (Vault_Speed / 100) * Perk_Module.Tiers[Tier]
	
	_G.GetValue(Player.Name, "WindowVaultSpeed"):Add("NaturalAcrobat", -Vault_Speed, -1)
end

return this
