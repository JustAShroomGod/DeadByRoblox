local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local module = {}

function module.Start()
	
	if (Scripts.Killer.Value) then
		return
	end
	
	LocalCharacter:GetAttributeChangedSignal("Soul_Bound"):Connect(Update)
end

function Update()
	
	if (LocalCharacter:GetAttribute("Soul_Bound") == nil) then
		return
	end
	
	for i, obj in pairs(workspace:GetChildren()) do
		if (string.find(obj.Name, "Hiding_Spot") == nil) then
			continue
		end
		
		if (GetDistanceXZ(obj) > 60) then
			continue
		end
		
		Auras.AddAura("Objects", 5, obj, false, `{obj.Name}_SoulBound`)
	end
	
end

function GetDistanceXZ(Object: Model)

	if (Object == nil) then
		return 999
	end

	local PositionLocal = LocalCharacter.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = Object.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
