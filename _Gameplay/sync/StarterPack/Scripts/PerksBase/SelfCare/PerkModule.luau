local Events = require(game.ServerScriptService["Event System"].Events)
local Code = require(game.ReplicatedStorage.Modules.Code)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('SelfCare'))
local RunService = game:GetService("RunService")

local this = {}

this.Player = nil
this.initialized = false
this.Heartbeat = nil
this.Tier = 0
this.last = 0
this.initTime = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	this.initTime = tick()
	
	local Scripts = this.Player.Backpack.Scripts

	local Perk = script.Parent
	local Multiplier = Perk:GetAttribute("Tier" .. Tier)
	local Action = Scripts:WaitForChild('values'):WaitForChild('Action')
	
	Action.Changed:Connect(OnActionChange)
end

function OnActionChange(Action)
	
	if (Action == "SelfHealing") then
		local Penalty = 1 - Perk_Module.Tiers[this.Tier]
		
		_G.GetValue(this.Player.Name, "HealingSpeed"):Add("SelfCare", -(Code.BaseValues.Survivor.Action.HealingSpeed * Penalty), nil)
	else
		_G.GetValue(this.Player.Name, "HealingSpeed"):Remove("SelfCare")
	end
end

return this
