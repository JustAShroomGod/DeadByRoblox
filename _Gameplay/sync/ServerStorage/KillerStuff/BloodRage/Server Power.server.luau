local TweenService = game:GetService("TweenService")
local Players = game.Players

local PowerModel = script.Parent
local Addons = PowerModel.Addons

local Player = Players:GetPlayerFromCharacter(PowerModel.Parent)
local Character = Player.Character
local Humanoid = Character.Humanoid
local RootPart = Character.HumanoidRootPart
local Head = Character.Head

local Face_Type = {
	Normal = Head:FindFirstChild("Face_Normal");
	Rage = Head:FindFirstChild("Face_Rage");
}

local Code = require(game.ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(game.ReplicatedStorage.Modules:WaitForChild("Data"))
local Events = require(game.ServerScriptService["Event System"]:WaitForChild("Events"))

local Backpack = game.Players[Player.Name]:WaitForChild("Backpack")
local Scripts = Backpack:WaitForChild("Scripts")

local values = Scripts:WaitForChild("values")
local killerAction = values:WaitForChild("KillerAction")

local PowerValues = PowerModel.PowerValues
local PowerRemote = PowerValues.PowerRemote
local initialized = false

local AllowedBreaks = {"Wall", "Pallet"}

local States = {
	["Idle"] = 0;
	["Rage"] = 1;
	["Fatigue"] = 2;
}

local Speeds = {
	["Movement"] = Code:GetSpeed("Movement", Player);
	["Fatigue"] = Code:GetSpeed("Fatigue", Player);
	["Rage"] = Code:GetSpeed("Rage", Player);
}

local Power = {
	["State"] = PowerModel:GetAttribute("State"),
	["Progress"] = PowerModel:GetAttribute("Progress")
}

local Limits = {
	["Drain"] = PowerValues:GetAttribute("Drain"),
	["BreakGain"] = PowerValues:GetAttribute("BreakGain"),
	["AttackGain"] = PowerValues:GetAttribute("AttackGain"),
	["AuraDistance"] = PowerValues:GetAttribute("AuraDistance"),
	["PassiveCharge"] = PowerValues:GetAttribute("PassiveCharge"),
	["PassiveChargeCap"] = PowerValues:GetAttribute("PassiveChargeCap"),
}

function initialize()
	initialized = true
	
	local Addons_Data = Data:GetAddons("Killer", game.Players[Player.Name])

	for _,Addon in pairs(Addons_Data) do
		if (Addons:FindFirstChild(Addon) ~= nil) then
			local AddonModule = require(Addons[Addon])
			AddonModule.init()
		end
	end

end

function onServerTick(delta)

	updateAttributes()
	updateSpeed(Power.State)

	if (not initialized) then
		initialize()
		return
	end

	if (Power.State == States.Idle and killerAction.Value == "Nothing") then
		
		if (Power.Progress > Limits.PassiveChargeCap) then
			return
		end
		
		local Progress = Power.Progress + (Limits.PassiveCharge * delta)

		setValue("Progress", math.clamp(Progress, 0, Limits.PassiveChargeCap))
		Humanoid.WalkSpeed = Speeds.Movement
		
	elseif (Power.State == States.Rage) then
		
		local Progress = Power.Progress - (Limits.Drain * delta)
		
		setValue("Progress", math.clamp(Progress, 0, Limits.PassiveChargeCap))
		
		if (Progress <= 0) then
			endRage(true)
		end
	end

end

function onAttack(Result)
	
	if (Result ~= "Hit" or Power.State ~= States.Idle) then
		return
	end
	
	local Progress = Power.Progress + Limits.AttackGain
	setValue("Progress", math.clamp(Progress, 0, 100))
	
end

function onBreak(Player, Type)
	
	if (not table.find(AllowedBreaks, Type) or Power.State ~= States.Idle) then
		return
	end
	
	local Progress = Power.Progress + Limits.BreakGain
	setValue("Progress", math.clamp(Progress, 0, 100))
end

function onGrasp(EventPlayer)
	if (EventPlayer.Name ~= Player.Name) then
		return
	end
	
	endRage(false)
end

function onStun(Type, EventPlayer)
	if (EventPlayer.Name ~= Player.Name) then
		return
	end
	
	endRage(false)
end

function onLockerSearch(EventPlayer)
	if (EventPlayer.Name ~= Player.Name) then
		return
	end
	
	endRage(false)
end

function onRemoteReceive(RemotePlayer, Command, ...)
	
	local args = {...}
	
	if (RemotePlayer.Name == Player.Name) then
		
		if (Command == "FatigueEnd") then
			endFatigue()
		end
		
		if (Command == "Input" and args[1] == true) then
			if (Power.State == States.Idle) then
				beginRage()
			elseif (Power.State == States.Rage) then
				endRage(true)
			end
		end
		
	end
end

function beginRage()
	
	if (Power.State ~= States.Idle or killerAction.Value ~= "Nothing" or Power.Progress < 100 or Player.Character:GetAttribute("Carry")) then
		return
	end
	
	local RecoveryDebuff = Code.BaseValues.Killer.Action.WipeSpeed * 0.1
	local PalletBreakBuff = Code.BaseValues.Killer.Action.PalletBreakSpeed * 0.8
	local WallBreakBuff = Code.BaseValues.Killer.Action.WallBreakSpeed * 0.8
	
	_G.GetValue(Player, "WipeSpeed"):Add("BloodRage", -RecoveryDebuff, nil)
	_G.GetValue(Player, "PalletBreakSpeed"):Add("BloodRage", PalletBreakBuff, nil)
	_G.GetValue(Player, "WallBreakSpeed"):Add("BloodRage", WallBreakBuff, nil)
	
	PowerRemote:FireClient(Players[Player.Name], "startRage")
	setValue("State", States.Rage)
	
	Data:GiveBlood(Player, 100, "Deviousness", "HOTFOOT")
	
	Face_Type.Normal.Transparency = 1
	Face_Type.Rage.Transparency = 0
end
	
function endRage(playFatigue: boolean)
	
	if (Power.State ~= States.Rage) then
		return
	end
	
	repeat wait() until killerAction.Value == "Nothing" or killerAction.Value == "Fatigue"
	
	setValue("State", States.Idle)
	PowerRemote:FireClient(Players[Player.Name], "stopRage")
	
	if (playFatigue) then
		setValue("Progress", 0)
		killerAction.Value = "Fatigue"
		setValue("State", States.Fatigue)
		PowerRemote:FireClient(Players[Player.Name], "startFatigue")
	end
	
	_G.GetValue(Player, "WipeSpeed"):Remove("BloodRage")
	_G.GetValue(Player, "PalletBreakSpeed"):Remove("BloodRage")
	_G.GetValue(Player, "WallBreakSpeed"):Remove("BloodRage")
	
	Face_Type.Normal.Transparency = 0
	Face_Type.Rage.Transparency = 1
end

function endFatigue()
	killerAction.Value = "Nothing"
	setValue("State", States.Idle)
end

function updateSpeed(State)
	
	if (State == States.Idle or (killerAction.Value ~= "Nothing" and killerAction.Value ~= "Fatigue")) then
		return
	end
	
	if (State == States.Rage and killerAction.Value == "Nothing") then
		Humanoid.WalkSpeed = Speeds.Rage
	end
	
	if (State == States.Fatigue or killerAction.Value == "Fatigue") then
		Humanoid.WalkSpeed = Speeds.Fatigue
	end
	
end

function updateAttributes()
	Power = {
		["State"] = PowerModel:GetAttribute("State"),
		["Progress"] = PowerModel:GetAttribute("Progress")
	}
end

function setValue(Attribute, Value)
	PowerModel:SetAttribute(Attribute, Value)
end

function getValue(Attribute)
	PowerModel:SetAttribute(Attribute)
end

PowerRemote.OnServerEvent:Connect(onRemoteReceive)
Events.Server.Heartbeat.Event:Connect(onServerTick)
Events.Killer.onAttack.Event:Connect(onAttack)
Events.Killer.onBreak.Event:Connect(onBreak)
Events.Killer.onStun.Event:Connect(onStun)
Events.Killer.onGrasp.Event:Connect(onGrasp)
Events.Killer.onLockerSearch.Event:Connect(onLockerSearch)
