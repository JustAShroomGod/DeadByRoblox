local Events = require(game.ServerScriptService["Event System"].Events)
local RunService = game:GetService("RunService")

local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('NoMither'))

local this = {}

this.Player = nil
this.initialized = false
this.Heartbeat = nil
this.Tier = 0
this.lastSpeed = 0
this.initTime = 0
this.Module = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Code"):WaitForChild('Status-Handler'))

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	this.Module:Set(Player.Character, "Ghost", -1, "NoMither")
end

return this