local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.Resourceful)

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
	
	local HasPerk, _Tier = Data:GetPerk("Resourceful")
	Tier = _Tier
	
	if (Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	RunService.Heartbeat:Connect(Update)
end

function Update()
	
	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end

	timestamp = workspace:GetServerTimeNow()
	
	for i, obj in pairs(workspace:GetChildren()) do
		
		if (string.find(obj.Name, "Pallet") == nil) then
			continue
		end
		
		if (not LocalCharacter:GetAttribute("Resourceful")) then
			Auras.RemoveAura(`{obj.Name}_Resourceful`, "Objects")
			continue
		end
		
		if (tonumber(LocalCharacter:GetAttribute("Resourceful")) >= Perk.Tiers[Tier] or obj.Panel.State.Value ~= 2 or obj:GetAttribute("Resource") or GetDistanceXZ(obj) > Perk.Aura_Distance) then
			Auras.RemoveAura(`{obj.Name}_Resourceful`, "Objects")
			continue
		end

		Auras.AddAura("Objects", -1, obj, false, `{obj.Name}_Resourceful`)
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
