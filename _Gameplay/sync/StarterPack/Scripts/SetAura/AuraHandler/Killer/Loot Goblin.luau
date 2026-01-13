local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Code = require(ReplicatedStorage.Modules.Code)
local Data = require(ReplicatedStorage.Modules.Data)
local Auras = require(ReplicatedStorage.Modules.Auras)
local Perk = require(game.ReplicatedStorage.Game_Data.Perks.Killer["Loot Goblin"])

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
	
	local HasPerk, _Tier = Data:GetPerk("Loot Goblin")
	Tier = _Tier
	
	if (not Scripts.Killer.Value or not HasPerk) then
		return
	end
	
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do

		if (plr.Name == LocalPlayer.Name) then
			continue
		end
		
		local backpack = plr.Backpack
		local scripts = backpack.Scripts
		local values = scripts.values
		
		values.Action.Changed:Connect(ActionUpdate)
	end
end

function ActionUpdate()
	for i, plr: Player in pairs(Teams.Survivor:GetPlayers()) do
		
		if (plr.Name == LocalPlayer.Name) then
			continue
		end
		
		if (string.find(Code:GetSurvivorAction(plr), "ChestSearch")) then
			Auras.AddPlayerAura("Hostile", -1, plr, `{plr.Name}_LootGoblin`)
		else
			Auras.RemovePlayerAura(`{plr.Name}_LootGoblin`, "Hostile")
		end
	end
	
end

module.Start()

return module
