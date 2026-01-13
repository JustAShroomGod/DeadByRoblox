local Events = require(game.ServerScriptService["Event System"].Events)
local RunService = game:GetService("RunService")

local Folder = script.Parent
local Code = require(game.ReplicatedStorage.Modules.Code)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild('WellMakeIt'))

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
	this.initTime = tick()
	
	Folder:SetAttribute("MaxCooldown", Perk_Module.Tiers[Tier]) -->> set the max cd for us
	Folder:SetAttribute("Timer", 0)
	
	RunService.Heartbeat:Connect(OnUpdate)
end

function OnUpdate(delta)

	local Timer = Folder:GetAttribute("Timer")

	if (Timer <= 0) then
		_G.GetValue(this.Player.Name, "HealingSpeed"):Remove("WellMakeIt")
	else
		Timer -= delta
		Folder:SetAttribute("Timer", Timer)
	end
end

function onHookRescue(Rescuer)
	if (Rescuer.Name ~= this.Player.Name) then
		return
	end
	
	script.Parent:SetAttribute('Timer', Perk_Module.Tiers[this.Tier]) -->> reset our time left or set it
	_G.GetValue(this.Player.Name, "HealingSpeed"):Add("WellMakeIt", Code.BaseValues.Survivor.Action.HealingSpeed, -1)
end

Events.Survivor.onHookRescue.Event:Connect(onHookRescue)

return this
