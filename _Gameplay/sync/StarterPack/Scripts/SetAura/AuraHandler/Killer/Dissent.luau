local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Killer.Dissent)

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

	local HasPerk, _Tier = Data:GetPerk("Dissent")
	Tier = _Tier

	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end

	for i, v in pairs(workspace:GetChildren()) do
		if (string.find(v.Name, "Generator")) then
			v.Panel.CurrentPlayersRepairing.Changed:Connect(function()
				RepairCountUpdate(v)
			end)
		end
	end
end

function RepairCountUpdate(Generator)
	
	if (GetDistanceXZ(Generator) > Perk.Tiers[Tier]) then
		Auras.RemoveAura(`{Generator.Name}_Dissent`, "Special", true)
		return
	end

	if (Generator.Panel.CurrentPlayersRepairing.Value >= 2) then
		Auras.AddAura("Special", -1, Generator, false, `{Generator.Name}_Dissent`)
	else
		Auras.RemoveAura(`{Generator.Name}_Dissent`, "Special", true)
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
