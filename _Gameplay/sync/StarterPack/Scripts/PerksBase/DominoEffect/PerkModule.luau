local Code = require(game.ReplicatedStorage.Modules.Code)
local Events = require(game.ServerScriptService["Event System"].Events)

local Data_Module = require(game.ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Data'))
local Perk_Module = require(game.ReplicatedStorage:WaitForChild('Game_Data'):WaitForChild('Perks'):WaitForChild('Killer'):WaitForChild("DominoEffect"))

local this = {}

this.Player = nil
this.initialized = false
this.Tier = 0

local function returnHighestProgressedGenerator()
	local Generator = nil

	for _, v in pairs(workspace:GetChildren()) do
		if not (v:IsA("Model")) or not (string.match(v.Name,"Generator")) then
			continue
		end

		if not Generator then
			Generator = v
		else
			if v:FindFirstChild("Panel"):FindFirstChild("Progress").Value >= 1000 or v:FindFirstChild("Panel"):FindFirstChild("Popped").Value then
				continue
			end
			
			if Generator:FindFirstChild("Panel"):FindFirstChild("Progress").Value < v:FindFirstChild("Panel"):FindFirstChild("Progress").Value then
				Generator = v
			else
				continue
			end
		end
	end

	return Generator
end

function OnUpdate(delta)
	local Timer = script.Parent:GetAttribute("Timer")
	if Timer > 0 then
		Timer -= delta
		script.Parent:SetAttribute("Timer", math.clamp(Timer,0,999))
	else
		if not (Timer == 0) then
			script.Parent:SetAttribute("Timer",0)
		end

		if not (script.Parent:GetAttribute("Target") == "") then
			script.Parent:SetAttribute("Target","")
		end

		return
	end
end

function onHookRescue(Rescuer)
	if script.Parent:GetAttribute("Active") then
		return
	end

	if not (script.Parent:GetAttribute("Timer") == 0) then
		return
	end

	if not (script.Parent:GetAttribute("Target") == "") then
		return
	end

	script.Parent:SetAttribute("Target",Rescuer.Name)
	script.Parent:SetAttribute("Timer",Perk_Module.Tiers[this.Tier])
	script.Parent:SetAttribute("MaxTimer",Perk_Module.Tiers[this.Tier])
end

function OnAttack(State, Name)
	if (State ~= "Hit") then
		return
	end

	if script.Parent:GetAttribute("Active") then
		return
	end

	if not (script.Parent:GetAttribute("Timer") > 0) then
		return
	end

	if not tostring(script.Parent:GetAttribute("Target") == tostring(Name)) then --not the player we want
		return
	end

	local HitPlayer = game.Players[Name]
	local HealthState = HitPlayer:FindFirstChild("Backpack"):FindFirstChild("Scripts"):FindFirstChild("values"):FindFirstChild("HealthState")

	if HealthState.Value == 0 then
		local Generator = returnHighestProgressedGenerator()

		script.Parent:SetAttribute("Active", true)
		script.Parent:SetAttribute("Timestamp",workspace:GetServerTimeNow())

		_G.GetObjectValue(Generator.Name, "Blocked").Add("DominoEffect", 1, Perk_Module.Block_Length)

		Generator:GetAttributeChangedSignal("Blocked"):Once(function()
			script.Parent:SetAttribute("Active", false)
		end)
	end
end

function this.initialize(Player: Player, Tier: number) : "Called when loading the Perk"
	if (this.initialized) then
		return
	end

	this.initialized = true
	this.Player = Player
	this.Tier = Tier

	Events.Survivor.onHookRescue.Event:Connect(onHookRescue)
	Events.Killer.onAttack.Event:Connect(OnAttack)
	Events.Server.Heartbeat.Event:Connect(OnUpdate)
end

return this
