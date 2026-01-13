local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Pop Goes The Weasel"))

local this = {}

this.Player = nil
this.initialized = false
this.Runner = nil
this.Tier = 0

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	Events.Killer.onBreak.Event:Connect(OnBreak)
	Events.Killer.onHook.Event:Connect(OnHook)
	
	script.Parent:SetAttribute("MaxCooldown", Perk_Module.Tiers[this.Tier])
end

function OnBreak(Player: Player, Type, ...)
	
	if (Player.Name ~= this.Player.Name or Type ~= "Generator") then
		return
	end
	
	local args = {...}
	local Generator = args[1]
	local Generator_Settings = Generator:WaitForChild('Panel')
	local Timer = script.Parent:GetAttribute("Timer")
	
	if (Timer > 0) then
		Generator_Settings.Progress.Value -= math.clamp((Perk_Module.Regression_Bonus * 10), 0, 1000)
		script.Parent:SetAttribute("Timer", 0)
		DisconnectTimer()
	end
end

function OnHook(Player: Player, Survivor: Player, Hook: Model)
	
	if (Player.Name ~= this.Player.Name) then
		return
	end
	
	local RefreshTimer = Perk_Module.Tiers[this.Tier]
	script.Parent:SetAttribute("Timer", RefreshTimer)
	ConnectTimer()
end

function ConnectTimer()
	
	DisconnectTimer()
	
	this.Runner = Events.Server.Heartbeat.Event:Connect(function(delta)
		
		local Timer = script.Parent:GetAttribute("Timer")
		script.Parent:SetAttribute("Timer", math.clamp(Timer - delta, 0, 999))
	end)
end

function DisconnectTimer()
	if (this.Runner == nil) then
		return
	end
	
	this.Runner:Disconnect()
	this.Runner = nil
	
end

return this
