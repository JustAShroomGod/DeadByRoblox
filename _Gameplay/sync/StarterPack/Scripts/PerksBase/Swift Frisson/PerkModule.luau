local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Swift Frisson"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0
this.Runner = nil

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	Events.Killer.onGrasp.Event:Connect(OnPickUp)

	script.Parent:SetAttribute("Timer", Perk_Module.Blocked_Duration)
	script.Parent:SetAttribute("MaxCooldown", Perk_Module.Blocked_Duration)
end

function OnUpdate(delta)

	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local OnCooldown = script.Parent:GetAttribute("OnCooldown")
	local Timer = script.Parent:GetAttribute("Timer")

	if (OnCooldown) then
		Timer += delta
		script.Parent:SetAttribute("Timer", Timer)

		if (Timer >= MaxCooldown) then
			script.Parent:SetAttribute("OnCooldown", false)
		end
	else
		if (Timer <= 0) then
			return
		end

		Timer += delta
		script.Parent:SetAttribute("Timer", Timer)

		if (Timer >= MaxCooldown) then
			BlockAll(false)
			script.Parent:SetAttribute("OnCooldown", true)
			script.Parent:SetAttribute("Timer", 0)
			script.Parent:SetAttribute("MaxCooldown", Perk_Module.Tiers[this.Tier])
		end
	end
end

function OnPickUp(Killer: Player, Survivor: Player)
	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local OnCooldown = script.Parent:GetAttribute("OnCooldown")
	local Timer = script.Parent:GetAttribute("Timer")

	if (Killer.Name == this.Player.Name and not script.Parent:GetAttribute("OnCooldown") and Timer >= MaxCooldown) then
		BlockAll(true)
		script.Parent:SetAttribute("OnCooldown", false)
		script.Parent:SetAttribute("Timer", Perk_Module.Blocked_Duration)
		script.Parent:SetAttribute("MaxCooldown", Perk_Module.Blocked_Duration)

		Disconnect()
		this.Runner = Events.Server.Heartbeat.Event:Connect(StartTimer)
	end

end

function BlockAll(bool)
	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Generator")) then
			if (bool) then
				if v.Panel.Progress.Value >= 300 and not v.Panel.BeingWorked.Value then
					_G.GetObjectValue(v.Name, "Blocked").Add("SwiftFrisson", 1, -1)
				end
			else
				_G.GetObjectValue(v.Name, "Blocked").Remove("SwiftFrisson")
			end
		end
	end
end

function StartCooldown(delta)
	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local OnCooldown = script.Parent:GetAttribute("OnCooldown")
	local Timer = script.Parent:GetAttribute("Timer")

	if (not OnCooldown) then
		return
	end

	Timer += delta
	script.Parent:SetAttribute("Timer", Timer)

	if (Timer >= MaxCooldown) then
		script.Parent:SetAttribute("OnCooldown", false)
	end
end

function StartTimer(delta)

	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local OnCooldown = script.Parent:GetAttribute("OnCooldown")
	local Timer = script.Parent:GetAttribute("Timer")

	if (Timer <= 0 or OnCooldown) then
		return
	end

	Timer -= delta
	script.Parent:SetAttribute("Timer", Timer)

	if (Timer <= 0) then
		BlockAll(false)
		script.Parent:SetAttribute("OnCooldown", true)
		script.Parent:SetAttribute("Timer", 0)
		script.Parent:SetAttribute("MaxCooldown", Perk_Module.Tiers[this.Tier])

		Disconnect()
		this.Runner = Events.Server.Heartbeat.Event:Connect(StartCooldown)
	end
end

function Disconnect()
	if (this.Runner) then
		this.Runner:Disconnect()
		this.Runner = nil
	end
end

return this