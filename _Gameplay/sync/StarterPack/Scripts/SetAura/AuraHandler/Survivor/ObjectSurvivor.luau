local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Survivor.ObjectOfObsession)

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent
local CustomRemote = Remotes.ClientToServer.CustomRemote

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local PerksBase = Scripts.PerksBase
local PerkFolder = PerksBase.ObjectOfObsession

local Tier = 0
local timestamp = workspace:GetServerTimeNow()


local module = {}

function module.Start()
	
	local HasPerk, _Tier = Data:GetPerk("ObjectOfObsession")
	Tier = _Tier
	
	if (Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	PerkFolder:GetAttributeChangedSignal("Watching"):Connect(UpdateAura)
	RunService.Heartbeat:Connect(Update)
end

function Update()

	if ((workspace:GetServerTimeNow() - timestamp) < 0.5) then
		return
	end

	timestamp = workspace:GetServerTimeNow()

	local obsession_boost = if (Code:IsObsession(LocalPlayer)) then Perk.Obsession_Bonus else 0 
	local maxDistance = Perk.Tiers[Tier] + obsession_boost

	for i, plr: Player in pairs(Teams.Killer:GetPlayers()) do

		if (plr.Name == LocalPlayer.Name) then
			continue
		end

		if (GetDistanceXZ(plr.Character) > Perk.Min_Distance 
			and GetDistanceXZ(plr.Character) <= maxDistance 
			and GetAngleDiff(plr.Character) <= -0.95) then

			SendWatching(plr.Name)
			return
		end
	end

	SendWatching("NONE")
end

function UpdateAura()
	
	for i, v in pairs(Teams.Killer:GetPlayers()) do
		if (v.Name ~= PerkFolder:GetAttribute("Watching")) then
			Auras.RemovePlayerAura(`{v.Name}_Object`, "Hostile")
			continue
		end
		
		Auras.AddPlayerAura("Hostile", -1, v, `{v.Name}_Object`)
	end
	
end

function SendWatching(PlayerName)
	if (PerkFolder:GetAttribute("Watching") == PlayerName) then
		return
	end
	
	CustomRemote:FireServer("ObjectSet", PlayerName)
end

function GetAngleDiff(Character: Model)
	local camToKiller = (Camera.CFrame.Position - Character.PrimaryPart.Position).Unit
	local camLook = Camera.CFrame.LookVector

	return camToKiller:Dot(camLook)
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
