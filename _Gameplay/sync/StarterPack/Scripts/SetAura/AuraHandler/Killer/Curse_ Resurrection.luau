local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Killer["Curse: Resurrection"])

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

local Totems = {}

local module = {}

function module.Start()
	
	local HasPerk, _Tier = Data:GetPerk("Curse: Resurrection")
	Tier = _Tier
	
	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	CacheTotems()
	RunService.Heartbeat:Connect(Update)
end

function Update()
	
	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end
	
	timestamp = workspace:GetServerTimeNow()
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do
		
		if (plr.Name == LocalPlayer.Name) then
			continue
		end
		
		CheckAura(plr)
	end
	
end

function CheckAura(plr: Player)
	
	for count = 1, #Totems do
		local totem = Totems[count]
		
		if (GetDistanceXZ(plr.Character, totem) < Perk.Tiers[Tier] and totem.Panel.State.Value == 0) then
			Auras.AddPlayerAura("Hostile", -1, plr, `{plr.Name}_Resurrection`)
			return
		end
	end
	
	Auras.RemovePlayerAura(`{plr.Name}_Resurrection`, "Hostile")
end

function CacheTotems()
	for i, object in pairs(workspace:GetChildren()) do
		if (string.find(object.Name, "Totem") == nil) then
			continue
		end
		
		if not object:GetAttribute("Effect", "Curse: Resurrection") then
			continue
		end
		
		table.insert(Totems, object)
	end
end

function GetDistanceXZ(Character: Model, Totem: Model)

	if (Character == nil) then
		return 999
	end

	local PositionLocal = Totem.PrimaryPart.CFrame.Position
	PositionLocal = Vector3.new(PositionLocal.X, 0, PositionLocal.Z)

	local PositionTarget = Character.PrimaryPart.CFrame.Position
	PositionTarget = Vector3.new(PositionTarget.X, 0, PositionTarget.Z)

	return (PositionLocal - PositionTarget).Magnitude
end

module.Start()

return module
