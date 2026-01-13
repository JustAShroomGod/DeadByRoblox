local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules:WaitForChild("Code"))
local Data = require(ReplicatedStorage.Modules:WaitForChild("Data"))
local Auras = require(ReplicatedStorage.Modules:WaitForChild("Auras"))
local Perk = require(ReplicatedStorage.Game_Data.Perks.Killer:WaitForChild("BarbecueAndChilli"))

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local Tier = 0

local module = {}

function module.Start()
	local HasPerk, _Tier = Data:GetPerk("BarbecueAndChilli")
	Tier = _Tier
	
	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	Scripts.PerksBase.BarbecueAndChilli:GetAttributeChangedSignal("timestamp"):Connect(PerkUpdated)
end

function PerkUpdated()
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do
		if (GetDistanceXZ(plr.Character) > Perk.Tiers[Tier]) then
			Auras.AddPlayerAura("Hostile", Perk.Length, plr, `{plr.Name}_BBQ`)
		end
	end
	
end

function GetDistanceXZ(Character: Model)
	
	if (Character == nil) then
		return 999
	end
	
	local PositionLocal = LocalCharacter.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)
	
	local PositionTarget = Character.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)
	
	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
