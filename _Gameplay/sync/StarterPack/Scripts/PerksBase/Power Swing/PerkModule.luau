local RunService = game:GetService("RunService")
local Code = require(game.ReplicatedStorage.Modules.Code)
local DataModule = require(game.ReplicatedStorage.Game_Data.Perks.Killer["Power Swing"])
local Events = require(game.ServerScriptService["Event System"].Events)
local Folder = script.Parent

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

	RunService.Heartbeat:Connect(OnUpdate)
	Events.Killer.onAttack.Event:Connect(OnAttack)

end

function OnUpdate(delta)

	local Timer = Folder:GetAttribute("Timer")
	local LungeSpeed = Code:GetPlayerValue(this.Player, "LungeSpeed")

	if (Timer <= 0) and this.Player.Character and this.Player.Character:GetAttribute("Carry") == nil  then
		_G.GetValue(this.Player.Name, "LungeSpeed"):Add("PowerSwing", DataModule.Speed_Bonus, nil)
	else
		Timer -= delta
		Folder:SetAttribute("Timer", Timer)
	end
end

function OnAttack()

	local Timer = Folder:GetAttribute("Timer")
	local Cooldown = DataModule.Tiers[this.Tier]

	if (Timer <= 0) then
		_G.GetValue(this.Player.Name, "LungeSpeed"):Remove("PowerSwing")
		Folder:SetAttribute("Timer", Cooldown)
	end
end

return this