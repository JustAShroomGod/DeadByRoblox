local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("StunningEncore"))

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
	
	script.Parent:SetAttribute("Cooldown", 0)
	
	Events.Killer.onHook.Event:Connect(OnHook)
	Events.Server.Heartbeat.Event:Connect(onUpdate)
end

function onUpdate(delta)
	local Cooldown = script.Parent:GetAttribute("Cooldown")
	Cooldown -= math.clamp(delta, 0, Perk_Module.Cooldown)
	script.Parent:SetAttribute("Cooldown", Cooldown)
end

function OnHook(Killer, Survivor, Hook: Model)
	
	local Cooldown = script.Parent:GetAttribute("Cooldown")
	
	if (Cooldown > 0) then
		return
	end
	
	for i, obj in pairs(workspace:GetChildren()) do
		if (string.find(obj.Name, "Hook")) then
			TriggerShockwave(obj)
		end
	end
	script.Parent:SetAttribute("Cooldown", Perk_Module.Cooldown)
end

function TriggerShockwave(Hook: Model)
	
	local Shockwave: Model = Hook.PrimaryPart.Shockwave
	local Radius = Perk_Module.Tiers[this.Tier] * 2
	local detonation = game.TweenService:Create(Shockwave, TweenInfo.new(Perk_Module.Travel_Time), {Size = Vector3.new(Radius, 1, Radius)})
	
	local touched = nil
	
	Shockwave.Transparency = 0
	detonation:Play()
	
	local function disconnect()
		if (touched ~= nil) then
			touched:Disconnect()
			touched = nil
		end
	end
	
	touched = Shockwave.Touched:Connect(function(part: Part)
		if (part.Parent == nil) then
			return
		end
		
		if (game.Players:FindFirstChild(part.Parent.Name) ~= nil) then
			local target: Player = game.Players[part.Parent.Name]
			
			if (target.Name == this.Player.Name) then
				return
			end
			
			if (target.Team == game.Teams.Survivor) then
				Code:Stun_Survivor(target, Perk_Module.Stun_Duration)
			end
		end
	end)

	detonation.Completed:Connect(function()
	local dissipation = game.TweenService:Create(Shockwave, TweenInfo.new(0.2), {Transparency = 1})
		dissipation:Play()

		dissipation.Completed:Connect(function()
			Shockwave.Size = Vector3.new(1, 0, 0)
			Shockwave.Transparency = 1
			disconnect()
		end)
	end)
	
	
end

return this
