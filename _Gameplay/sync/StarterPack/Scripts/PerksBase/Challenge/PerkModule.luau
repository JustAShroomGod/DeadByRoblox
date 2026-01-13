local Events = require(game.ServerScriptService["Event System"].Events)
local Remotes = game.ReplicatedStorage.RemoteEvents
local Code_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Code'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("Challenge"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

this.CrouchTimer = {}

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier
	
	Events.Server.Heartbeat.Event:Connect(OnUpdate)
	script.Parent:SetAttribute("MaxCooldown", Perk_Module.Tiers[Tier])
end

function OnUpdate(delta)
	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local Cooldown = script.Parent:GetAttribute("Cooldown")
	
	if (Cooldown > 0) then
		script.Parent:SetAttribute("Cooldown", math.clamp(Cooldown - delta, 0, MaxCooldown))
	end
end

Remotes.Crouch.OnServerEvent:Connect(function(Survivor: Player)
	
	local MaxCooldown = script.Parent:GetAttribute("MaxCooldown")
	local Cooldown = script.Parent:GetAttribute("Cooldown")
	
	if (Cooldown > 0) then
		return
	end
	
	local PosK: Vector3 = this.Player.Character:GetPivot().Position
	local PosS: Vector3 = Survivor.Character:GetPivot().Position
	local Dist = (PosK - PosS).Magnitude
	
	if (Dist <= Perk_Module.Activation_Distance) then
		if (not this.CrouchTimer[Survivor.Name]) then
			this.CrouchTimer[Survivor.Name] = workspace:GetServerTimeNow()
		else
			local diff = (workspace:GetServerTimeNow() - this.CrouchTimer[Survivor.Name])
			if (diff < 6) then
				script.Parent:SetAttribute("Cooldown", MaxCooldown)
				Code_Module:SetEffect("Exposed", Survivor, Perk_Module.Exposed_Time, "Challenge")
			end
			this.CrouchTimer[Survivor.Name] = workspace:GetServerTimeNow()
		end
	end
end)


return this
