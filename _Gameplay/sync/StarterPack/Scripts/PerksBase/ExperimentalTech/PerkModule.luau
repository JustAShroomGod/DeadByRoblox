local Events = require(game.ServerScriptService["Event System"].Events)
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Utils = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PerkUtils"))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Survivor'):WaitForChild("ExperimentalTech"))

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
	
	script.Parent:SetAttribute("Cooldown", Perk_Module.Tiers[Tier])
	script.Parent:SetAttribute("MaxCooldown", Perk_Module.Tiers[Tier])
	
	script.Parent:SetAttribute("Duration", Perk_Module.Cloak_Duration)
	script.Parent:SetAttribute("MaxDuration", Perk_Module.Cloak_Duration)
	
	Events.Server.Heartbeat.Event:Connect(OnUpdate)
	Events.Survivor.onCustomEvent.Event:Connect(OnCustomEvent)
	Events.Killer.onAttack.Event:Connect(OnAttack)
	Player.Character:GetAttributeChangedSignal("Chased"):Connect(ChaseChanged)
end

function OnUpdate(delta)
	
	local Character = this.Player.Character
	
	if (Character == nil)  then
		return
	end
	
	local Cloaked = Code_Module:GetEffect("Cloaked", this.Player)

	if (Cloaked) then
		local Duration = script.Parent:GetAttribute("Duration")
		Duration -= delta
		
		script.Parent:SetAttribute("Duration", math.clamp(Duration, 0, script.Parent:GetAttribute("MaxDuration")))
		
		if (Duration <= 0) then
			script.Parent:SetAttribute("Cooldown", 0)
			Code_Module:SetEffect("Cloaked", this.Player, nil, "ExperimentalTech")
			script.Parent:SetAttribute("Duration", Perk_Module.Cloak_Duration)
		end
		
		return
	end
	
	if (not IsOffCooldown()) then
		local Cooldown = script.Parent:GetAttribute("Cooldown")
		script.Parent:SetAttribute("Cooldown", math.clamp(Cooldown + delta, 0, script.Parent:GetAttribute("MaxCooldown")))
	end
end

function OnCustomEvent(Type, ...)
	if (Type ~= "ExperimentalTech") then
		return
	end
	
	local args = {...}
	
	if (args[2].Name ~= this.Player.Name or not IsOffCooldown()) then
		return
	end
	
	if (args[1] == true) then
		
		if (this.Player.Character:GetAttribute("Chased") == true) then
			return
		end
		
		script.Parent:SetAttribute("Duration", Perk_Module.Cloak_Duration)
		Code_Module:SetEffect("Cloaked", this.Player, true, "ExperimentalTech")
	else
		script.Parent:SetAttribute("Cooldown", 0)
		script.Parent:SetAttribute("Duration", 0)
		Code_Module:SetEffect("Cloaked", this.Player, nil, "ExperimentalTech")
	end
end

function OnAttack(State, Player)
	
	if (State ~= "Hit" or Player ~= this.Player) then
		return
	end
	
	local Character = Player.Character
	local Cloaked = Code_Module:GetEffect("Cloaked", this.Player)

	if (Cloaked) then
		script.Parent:SetAttribute("Cooldown", 0)
		Code_Module:SetEffect("Cloaked", this.Player, nil, "ExperimentalTech")
	end
	
end

function ChaseChanged()
	
	if (this.Player.Character:GetAttribute("Chased")) then
		script.Parent:SetAttribute("Cooldown", 0)
		script.Parent:SetAttribute("Duration", 0)
		Code_Module:SetEffect("Cloaked", this.Player, nil, "ExperimentalTech")
	end
	
end

function IsOffCooldown()
	return (script.Parent:GetAttribute("Cooldown") >= script.Parent:GetAttribute("MaxCooldown"))
end

return this
