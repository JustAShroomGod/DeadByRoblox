local Players = game:GetService("Players")

local PowerModel = script.Parent.Parent
local PowerValues = PowerModel.PowerValues
local TimeScaleRef = nil

local Player: Player = Players:GetPlayerFromCharacter(PowerModel.Parent)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character.Humanoid
local RootPart = Character.HumanoidRootPart

local ValueDict = require(script.ValueDict)
local Code = require(game.ReplicatedStorage.Modules.Code)
local Data = require(game.ReplicatedStorage.Modules.Data)

local DilationSphere = {}

DilationSphere.ValueKey = "TimeDilation"

function DilationSphere.Init()
	TimeScaleRef = workspace.MatchValues.TimeScale
end

function DilationSphere.SpeedUp()
	TimeScaleRef.Value = math.clamp(TimeScaleRef.Value + 0.25, GetValue("Min_Scale"), GetValue("Max_Scale"))
end

function DilationSphere.SlowDown()
	TimeScaleRef.Value = math.clamp(TimeScaleRef.Value - 0.25, GetValue("Min_Scale"), GetValue("Max_Scale"))
end

function DilationSphere.Update(delta)
	for i, plr in pairs(Players:GetPlayers()) do
		
		if (GetDistanceToPlayer(plr) > GetValue("Dilation_Radius") or TimeScaleRef.Value == 1) then
			DilationSphere.SetModifiers(plr, 0)
			continue
		end
		
		local distanceMultiplier = 1
		
		if (GetDistanceToPlayer(plr) < GetValue("Drop_Off_Distance") and not Code:isKiller(plr)) then
			distanceMultiplier = (0.5 / GetValue("Drop_Off_Distance") * GetDistanceToPlayer(plr))
		end
		
		if (TimeScaleRef.Value < 1) then
			local effectiveness = (1 - TimeScaleRef.Value)
			effectiveness *= if (Code:isKiller(plr)) then GetValue("Killer_Effectiveness") else 1
			effectiveness *= distanceMultiplier

			DilationSphere.SetModifiers(plr, -effectiveness)
			return
		end

		local effectiveness = (TimeScaleRef.Value - 1)
		effectiveness *= if (Code:isKiller(plr)) then GetValue("Killer_Effectiveness") else 1
		effectiveness *= distanceMultiplier

		DilationSphere.SetModifiers(plr, effectiveness)
	end
end

function DilationSphere.SetModifiers(player: Player, effectiveness: number)
	for attr, invert in pairs(ValueDict.Get()) do
		
		if (_G.GetValue(player.Name, attr) == nil) then
			continue
		end
		
		if (effectiveness == 0) then
			_G.GetValue(player.Name, attr):Remove(DilationSphere.ValueKey)
			continue
		end
		
		effectiveness = if (invert) then -effectiveness else effectiveness
		_G.GetValue(player.Name, attr):Add(DilationSphere.ValueKey, effectiveness, -1)
	end
end

function GetDistanceToPlayer(Target)
	local character = Target.Character or Target.CharacterAdded:Wait()
	local rootPart = character.HumanoidRootPart
	
	local playerXZ = Vector3.new(RootPart.CFrame.Position.X, 0, RootPart.CFrame.Position.Z)
	local targetXZ = Vector3.new(rootPart.CFrame.Position.X, 0, rootPart.CFrame.Position.Z)
	
	return (playerXZ - targetXZ).Magnitude
end

function SetValue(Attribute, Value)
	PowerValues:SetAttribute(Attribute, Value)
end

function GetValue(Attribute)
	return PowerValues:GetAttribute(Attribute)
end

return DilationSphere
