local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.Focused)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local Tier = 0
local timestamp = workspace:GetServerTimeNow()

local module = {}

function module.Start()
	
	local HasPerk, _Tier = Data:GetPerk("Focused")
	Tier = _Tier
	
	if (Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	Teams.Survivor.PlayerRemoved:Connect(PlayerRemoved)
end

function PlayerRemoved()
	
	if (#Teams.Survivor:GetPlayers() > 1) then
		Auras.RemoveAura(`Hatch_Focused`, "Objects", false)
		return
	end
	
	RunService.Heartbeat:Connect(Update)
end

function Update()
	
	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end

	timestamp = workspace:GetServerTimeNow()

	if (GetDistanceXZ(LocalCharacter) >= Perk.MinDistance and GetDistanceXZ(LocalCharacter) <= Perk.MaxDistance) then
		Auras.AddAura("Objects", -1, workspace.Hatch, false, `{workspace.Hatch.Name}_Focused`)
	else
		Auras.RemoveAura(`Hatch_Focused`, "Objects", false)
	end
end

function GetDistanceXZ(Character: Model)

	if (Character == nil) then
		return 999
	end

	local PositionLocal = LocalCharacter.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = workspace.Hatch.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
