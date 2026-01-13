local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("CriticalStrike"))

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
	
	Events.Killer.onAttack.Event:Connect(OnAttack)
	Events.Server.Heartbeat.Event:Connect(OnUpdate)
	Events.Survivor.onHealingFinished.Event:Connect(OnHealingFinished)
	
	
	script.Parent:SetAttribute("MaxTimer", Perk_Module.Tiers[Tier])
end

function OnUpdate(delta)
	
	local MaxTimer = script.Parent:GetAttribute("MaxTimer")
	local Timer = script.Parent:GetAttribute("Timer")
	
	if (Timer > 0) then
		Timer = math.clamp(Timer - delta, 0, MaxTimer)
		script.Parent:SetAttribute("Timer", Timer)
	end
	
end

-- require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code')):SetEffect("Slow", game.Players.VeroxCode, {10, 20}, "Test")

function OnAttack(State, PlayerName)
	
	if (State ~= "Hit" or PlayerName == nil) then
		return
	end
	
	local random = math.random(0, 100)
	local Player = game.Players[PlayerName]
	
	local IFrame, AFrame = Code_Module:GetEffect("IFrame", Player), Code_Module:GetEffect("AFrame", Player)
	local MaxTimer = script.Parent:GetAttribute("MaxTimer")
	local Timer = script.Parent:GetAttribute("Timer")
	
	if (Timer > 0) then
		if (AFrame and AFrame.Active) or (IFrame and IFrame.Active) then
			return
		end
		
		Code_Module:SetEffect("Slow", Player, {Perk_Module.Slowness_Duration, Perk_Module.Slowness_Percentage}, "CriticalStrike")
		Code_Module:SetEffect("Broken", Player, Perk_Module.Broken_Duration, "CriticalStrike")
	end
end

function OnHealingFinished(Survivor, Healers)
	local MaxTimer = script.Parent:GetAttribute("MaxTimer")
	script.Parent:SetAttribute("Timer", MaxTimer)
end

return this