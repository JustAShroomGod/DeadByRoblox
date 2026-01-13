local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Survivor["The Savier"])

local Remotes = ReplicatedStorage.RemoteEvents
local AuraEvent = Remotes.ServerToClient.AuraEvent

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AuraFolder = workspace.Auras

local Backpack = LocalPlayer.Backpack
local Scripts = Backpack.Scripts
local Values = Scripts.values

local timestamp = workspace:GetServerTimeNow()
local HasPerkCache = {}

local module = {}

function module.Start()
	
	if (Scripts.Killer.Value) then
		return
	end
	
	local StartRunner = CacheHasPerk()
	
	if (not StartRunner) then
		return
	end
	
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
		
		if (Code:IsHooked("Any") and HasPerkCache[plr.Name]) then
			Auras.AddPlayerAura("Ally", -1, plr, `{plr.Name}_Savier`)
			continue
		end
		
		Auras.RemovePlayerAura(`{plr.Name}_Savier`, "Ally")
	end
	
end

function CacheHasPerk()
	
	local bool = false
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do

		if (plr.Name == LocalPlayer.Name) then
			continue
		end

		local hasPerk, tier = Data:GetPerk("The Savier", plr)
		HasPerkCache[plr.Name] = hasPerk
		
		bool = if (hasPerk and not bool) then true else bool
	end
	
	return bool
end


module.Start()

return module
